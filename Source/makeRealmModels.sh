#!/bin/bash

#
#  makeRealmModels.command
#  SwaggerToSwift
#
#  Created by Anton Plebanovich on 7/31/17.
#  Copyright © 2017 Anton Plebanovich. All rights reserved.
#

# This script converts swagger.json file into Swift models
# Usage: makeModel.command [swagger json file]
# Or place `swagger.json` file in same folder and run

# Configuration Constants
source_filename="swagger.json" # Swagger spec JSON file name
output_dir="." # Models output directory
type_casting_enabled=true # Enable type casting?
assert_values=true # Add value assertion checks? Only asserts mandatory values.
override_isEqual=true # Override Realm implementation of objects equality with properties comparison?
project_name="<#PROJECT_NAME#>" # Project name for header
user_name="$(echo $USER || git config user.name)" # User name for header
company_name="<#COMPANY_NAME#>" # Company name for header

# Params parsing
usage() {
    echo -e "Swagger JSON spec to Swift ObjectMapper models converter"
    echo -e ""
    echo -e "./makeModels.sh"
    echo -e "\t-h\t--help\t\t\t\t\tShow help"
    echo -e "\t-f\t--file\t\t\t\t\tSpecify swagger spec JSON file name. Default - 'swagger.json'."
    echo -e "\t-o\t--output-dir\t\t\t\tModels output directory. Default - same as script file location."
    echo -e "\t-t\t--type-casting-enabled\t\t\tEnable type casting? Default - true."
    echo -e "\t-a\t--assert-values\t\t\t\tAdd value assertion checks? Only asserts mandatory values. Default - true."
    echo -e "\t-oi\t--override-isEqual\t\t\tOverride Realm implementation of objects equality with properties comparison? Default - true."
    echo -e "\t-p\t--project-name\t\t\t\tProject name for header. Default - <#PROJECT_NAME#>."
    echo -e "\t-u\t--user-name\t\t\t\tCompany name for header. Default - \$USER or git user name."
    echo -e "\t-c\t--company-name\t\t\t\tCompany name for header. Default - <#COMPANY_NAME#>."
    echo -e ""
}

assertBoolParam() {
    if [[ "$1" != "true" && "$1" != "false" ]]; then
        echo "Wrong param value '$1'. Should be 'true' or 'false'."
        exit 1
    fi
}

while [[ "$1" != "" ]]; do
    PARAM=$1
    VALUE=$2

    case $PARAM in
        -h | --help)
            usage
            shift
            exit
            ;;
        -f | --file)
            source_filename=$VALUE
            shift 2
            ;;
        -o | --output-dir)
            output_dir=$VALUE
            shift 2
            ;;
        -t | --type-casting-enabled)
            assertBoolParam $VALUE
            type_casting_enabled=$VALUE
            shift 2
            ;;
        -a | --assert-values)
            assertBoolParam $VALUE
            assert_values=$VALUE
            shift 2
            ;;
        -oi | --override-isEqual)
            assertBoolParam $VALUE
            override_isEqual=$VALUE
            shift 2
            ;;
        -p | --project-name)
            project_name=$VALUE
            shift 2
            ;;
        -u | --user-name)
            user_name=$VALUE
            shift 2
            ;;
        -c | --company-name)
            company_name=$VALUE
            shift 2
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
done

# Colors Constants
red_color='\033[0;31m'
green_color='\033[0;32m'
blue_color='\033[0;34m'
no_color='\033[0m'

# Helper Functions
getSwiftTypeAndDefaultValueString () {
    default_value_string=""

    if [ "$1" == "string" ]; then
        swift_type="String"
    elif [ "$1" == "number" ]; then
        swift_type="Double"
        default_value_string=" = 0"
    elif [ "$1" == "integer" ]; then
        swift_type="Int"
        default_value_string=" = 0"
    elif [ "$1" == "boolean" ]; then
        swift_type="Bool"
        default_value_string=" = false"
    else
        return 1
    fi

    return 0
}

getAllowedPropertyName () {
    if [ "$1" == "description" ]; then
        allowed_property_name="descriptionString"
    else
        allowed_property_name=$1

        # Change underscore_name to underscoreName
        regex='(.*)_+(.*)'
        while [[ $allowed_property_name =~ $regex ]]; do
            second_part=${BASH_REMATCH[2]}
            capitalized_second_part="$(tr '[:lower:]' '[:upper:]' <<< ${second_part:0:1})${second_part:1}"
            allowed_property_name=${BASH_REMATCH[1]}${capitalized_second_part}
        done
    fi
}

# Requires `jq` installed - https://stedolan.github.io/jq/download/
# brew install jq

hash jq 2>/dev/null || { printf >&2 "\n${red_color}Requires jq installed - https://stedolan.github.io/jq/download/${no_color}\n\n"; exit 1; }

# ObjectMapper+Realm note
printf "\n${blue_color}ObjectMapper+Realm framework is required to cast custom type arrays into Realm lists - https://github.com/jakenberg/ObjectMapper-Realm${no_color}\n\n"

# ObjectMapperAdditions note
printf "${blue_color}ObjectMapperAdditions framework is required to cast Swift simple type arrays into Realm lists - https://github.com/APUtils/ObjectMapperAdditions${no_color}\n\n"

# Source file
if [[ -f $source_filename ]]; then
    printf "Parsing ${source_filename}...\n"
elif [[ -f "${source_filename}.json" ]]; then
    source_filename="${source_filename}.json"
    printf "Parsing ${source_filename}...\n"
else
    echo "ERROR! File not found"
    exit 1
fi

# Directories routine
base_dir=$(dirname "$0")
cd "$base_dir"
mkdir -p "$output_dir"

definitions="$(cat $source_filename | jq -r '.definitions | keys | .[]')"
definitions_dictionary="$(cat $source_filename | jq -r .definitions)"
for definition in $definitions; do
    # Definition dictionary
    definition_dictionary="$(echo $definitions_dictionary | jq -r .$definition)"

    # Creating models only for objects
    if [ "$(echo $definition_dictionary | jq -r .type)" != "object" ]; then
        continue
    fi

    # Output file
    output_filename="${output_dir}/${definition}.swift"
    printf "Generating '${definition}.swift' model..."

################################# Header and Imports #################################
    # Creating file with header and imports
    imports_string="import Foundation\n"
    imports_string="${imports_string}import ObjectMapper\n"
    imports_string="${imports_string}import ObjectMapper_Realm\n"
    imports_string="${imports_string}import ObjectMapperAdditions\n"
    imports_string="${imports_string}import RealmSwift\n"
    imports_string="${imports_string}import RealmAdditions\n"

    user_name="$(echo $USER || git config user.name)"
    printf "//\n//  $definition.swift\n//  $project_name\n//\n//  Created by $user_name on $(date +'%m/%d/%y').\n//  Copyright © $(date +'%Y') $company_name. All rights reserved.\n//\n\n$imports_string\n\n" > "$output_filename"

################################# Properties #################################
    # properties
    properties="$(echo $definition_dictionary | jq -r '.properties | keys_unsorted | .[]')"

    printf "class $definition: Object, Mappable {\n" >> "$output_filename"

    # Get required fields if they exist
    if [ "$(echo $definition_dictionary | jq -r 'has("required")')" == "true" ]; then
        required_fields="$(echo $definition_dictionary | jq -r '.required | .[]')"
    else
        required_fields=""
    fi

    transform_types=()
    for property in $properties; do
        getAllowedPropertyName $property
        # Swagger type
        type="$(echo $definition_dictionary | jq -r .properties.$property.type)"

        # Handle object type
        if [ "$type" == "null" ]; then
            type="$(echo $definition_dictionary | jq -r .properties.$property.\"\$ref\" | cut -d/ -f3)"
        fi

        # Swift type
        if getSwiftTypeAndDefaultValueString "$type"; then
            var_string="dynamic var"

            if $type_casting_enabled ; then
                transform_type="${swift_type}Transform()"
            else
                transform_type="none"
            fi

        elif [ "$type" == "array" ]; then
            var_string="var"
            array_subtype="$(echo $definition_dictionary | jq -r .properties.$property.items.type)"

            # Handle object subtype
            if [ "$array_subtype" == "null" ]; then
                type="$(echo $definition_dictionary | jq -r .properties.$property.items.\"\$ref\" | cut -d/ -f3)"
            fi

            if getSwiftTypeAndDefaultValueString "$array_subtype"; then
                array_subtype="Realm$swift_type"

                if $type_casting_enabled ; then
                    transform_type="RealmTypeCastTransform<$array_subtype>()"
                else
                    transform_type="RealmTransform<$array_subtype>()"
                fi

                default_value_string=" = List<$array_subtype>()"
            else
                array_subtype=$type
                transform_type="ListTransform<$array_subtype>()"
                default_value_string=" = List<$array_subtype>()"
            fi

            swift_type="List<$array_subtype>"
        else
            var_string="dynamic var"
            swift_type=$type
            transform_type="none"
        fi

        transform_types+=($transform_type)

        # Getting optionality type
        optional_type="?"
        if $assert_values; then
            for required_field in $required_fields; do
                if [[ "${property}" == "${required_field}" ]]; then
                    optional_type="!"
                    break
                fi
            done
        fi

        if [ ! -z "$default_value_string" ]; then
            optional_type=""
        fi

        # Appen file with properties
        printf "    $var_string $allowed_property_name: $swift_type$optional_type$default_value_string\n" >> "$output_filename"
    done
    printf "\n" >> "$output_filename"

################################# Init #################################
    # Append init section
    if $assert_values && [[ ! -z $required_fields ]]; then
        printf "    required convenience init?(map: Map) {\n" >> "$output_filename"
        echo $required_fields | xargs -n1 -I {} printf "        guard map.assureValuePresent(forKey: \"{}\") else { return nil }\n" >> "$output_filename"
        printf "\n        self.init()\n" >> "$output_filename"
        printf "    }\n\n" >> "$output_filename"
    else
        printf "    required convenience init?(map: Map) { self.init() }\n\n" >> "$output_filename"
    fi

################################# Mapping #################################
    # Append mapping section
    if [[ -z $properties ]]; then
        printf "    func mapping(map: Map) {}\n\n" >> "$output_filename"
    else
        printf "    func mapping(map: Map) {\n" >> "$output_filename"
        printf "        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false\n" >> "$output_filename"
        printf "        isWriteRequired ? realm?.beginWrite() : ()\n\n" >> "$output_filename"
        index=0
        for property in $properties; do
            getAllowedPropertyName $property

            # Get map expression
            if [ "${transform_types[$index]}" == "none" ]; then
                map_expression="map[\"${property}\"]"
            else
                map_expression="(map[\"${property}\"], ${transform_types[$index]})"
            fi

            printf "        ${allowed_property_name} <- ${map_expression}\n" >> "$output_filename"
            ((index++))
        done
        printf "\n        isWriteRequired ? try? realm?.commitWrite() : ()\n" >> "$output_filename"
        printf "    }\n" >> "$output_filename"
    fi

################################# Equatable #################################
    # Append equatable section
    if $override_isEqual; then
        printf "\n" >> "$output_filename"
        printf "    //-----------------------------------------------------------------------------\n" >> "$output_filename"
        printf "    // MARK: - Equatable\n" >> "$output_filename"
        printf "    //-----------------------------------------------------------------------------\n\n" >> "$output_filename"
        printf "    override func isEqual(_ object: Any?) -> Bool {\n" >> "$output_filename"
        printf "        guard let object = object as? $definition else { return false }\n\n" >> "$output_filename"
        if [[ -z $properties ]]; then
            printf "        return true\n" >> "$output_filename"
        else
            linePrefix="        return "
            for property in $properties; do
                getAllowedPropertyName $property
                printf "${linePrefix}${allowed_property_name} == object.${allowed_property_name}\n" >> "$output_filename"
                linePrefix="            && "
            done
        fi
        printf "    }\n" >> "$output_filename"
    fi

    printf "}\n" >> "$output_filename"
    printf " ${green_color}OK${no_color}\n"
done

################################# Done #################################
printf "\n${green_color}Done${no_color}\n\n"
