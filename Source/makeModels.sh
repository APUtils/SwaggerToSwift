#!/bin/bash

#
#  makeModels.command
#  SwaggerToSwift
#
#  Created by Anton Plebanovich on 7/31/17.
#  Copyright © 2017 Anton Plebanovich. All rights reserved.
#

# This script converts swagger.json file into Swift models
# Usage: makeModel.command [-f swagger json file]
# Or place `swagger.json` file in same folder and run
# Help: makeModel.command --help

# Configuration Constants
source_filename="swagger.json" # Swagger spec JSON file name
output_dir="." # Models output directory
type_casting_enabled=true # Enable type casting?
describable_enabled=true # Add Describable protocol conformance?
assert_values=true # Add value assertion checks? Only asserts mandatory values.
project_name="<#PROJECT_NAME#>" # Project name for header
user_name="$(echo $USER || git config user.name)" # User name for header
company_name="<#COMPANY_NAME#>" # Company name for header

# Params parsing
usage() {
    echo "Swagger JSON spec to Swift ObjectMapper models converter"
    echo ""
    echo "./makeModels.sh"
    echo "\t-h\t--help\t\t\t\t\tShow help"
    echo "\t-f\t--file\t\t\t\t\tSwagger spec JSON file name. Default - 'swagger.json'."
    echo "\t-o\t--output-dir\t\t\t\t\tModels output directory. Default - same as script file location."
    echo "\t-t\t--type-casting-enabled\t\t\tEnable type casting? Default - true."
    echo "\t-de\t--describable-enabled\t\t\tAdd Describable protocol conformance? Default - true."
    echo "\t-a\t--assert-values\t\t\t\tAdd value assertion checks? Only asserts mandatory values. Default - true."
    echo "\t-p\t--project-name\t\t\t\tProject name for header. Default - <#PROJECT_NAME#>."
    echo "\t-u\t--user-name\t\t\t\tCompany name for header. Default - $USER or git user name."
    echo "\t-c\t--company-name\t\t\t\tCompany name for header. Default - <#COMPANY_NAME#>."
    echo ""
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
        -de | --describable-enabled)
            assertBoolParam $VALUE
            describable_enabled=$VALUE
            shift 2
            ;;
        -a | --assert-values)
            assertBoolParam $VALUE
            assert_values=$VALUE
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

# $1 - Swagger type. Returns 0 for known type and 1 for unknown type.
getSwiftType () {
    if [ "$1" == "string" ]; then
        swift_type="String"
    elif [ "$1" == "number" ]; then
        swift_type="Double"
    elif [ "$1" == "integer" ]; then
        swift_type="Int"
    elif [ "$1" == "boolean" ]; then
        swift_type="Bool"
    else
        return 1
    fi

    return 0
}

# $1 - property name. Sets $allowed_property_name.
getAllowedPropertyName () {
    allowed_property_name=$1

    # Change underscore_name to underscoreName
    regex='(.*)_+(.*)'
    while [[ $allowed_property_name =~ $regex ]]; do
        second_part=${BASH_REMATCH[2]}
        capitalized_second_part="$(tr '[:lower:]' '[:upper:]' <<< ${second_part:0:1})${second_part:1}"
        allowed_property_name=${BASH_REMATCH[1]}${capitalized_second_part}
    done
}

# $1 - format, $2 - swift type. Sets $transform_type
getSwiftTypeAndTransformType () {
    if [ $1 == "date" ]; then
        swift_type="Date"
        transform_type="ISO8601JustDate"
    elif [ $1 == "date-time" ]; then
        swift_type="Date"
        transform_type="ISO8601Date"
    elif [ $1 == "timestamp" ]; then
        swift_type="Date"
        transform_type="Timestamp"
    else
        swift_type=$2
        transform_type=$2
    fi
}

# Requires `jq` installed - https://stedolan.github.io/jq/download/
# brew install jq

hash jq 2>/dev/null || { printf >&2 "\n${red_color}Requires jq installed - https://stedolan.github.io/jq/download/${no_color}\n\n"; exit 1; }

# Type casting note
printf "\n${blue_color}Type casting and values assertion requires ObjectMapperAdditions framework installed - https://github.com/APUtils/ObjectMapperAdditions${no_color}\n\n"

# Describable note
if $describable_enabled ; then
    printf "\n${blue_color}Describable protocol requires APExtensions framework installed - https://github.com/APUtils/APExtensions${no_color}\n\n"
fi

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

    if $describable_enabled ; then
        imports_string="${imports_string}import APExtensions\n"
    fi

    imports_string="${imports_string}import ObjectMapper\n"

    if $type_casting_enabled || $assert_values ; then
        imports_string="${imports_string}import ObjectMapperAdditions\n"
    fi

    printf "//\n//  $definition.swift\n//  $project_name\n//\n//  Created by $user_name on $(date +'%m/%d/%y').\n//  Copyright © $(date +'%Y') $company_name. All rights reserved.\n//\n\n$imports_string\n\n" > "$output_filename"

################################# Properties #################################
    # properties
    properties="$(echo $definition_dictionary | jq -r '.properties | keys_unsorted | .[]')"

    # Append file with struct declaration
    if $describable_enabled ; then
        protocols_string="Mappable, Describable"
    else
        protocols_string="Mappable"
    fi
    printf "struct $definition: $protocols_string {\n" >> "$output_filename"

    # Get required fields if they exist
    if [ "$(echo $definition_dictionary | jq -r 'has("required")')" == "true" ]; then
        required_fields="$(echo $definition_dictionary | jq -r '.required | .[]')"
    else
        required_fields=""
    fi

    init_params=""
    init_body=""

    transform_types=()
    for property in $properties; do
        getAllowedPropertyName $property
        # Swagger type
        type="$(echo $definition_dictionary | jq -r .properties.$property.type)"

        # Swagger format
        format="$(echo $definition_dictionary | jq -r .properties.$property.format)"

        # Handle object type
        if [ "$type" == "null" ]; then
            type="$(echo $definition_dictionary | jq -r .properties.$property.\"\$ref\" | cut -d/ -f3)"
        fi

        # Swift type
        if getSwiftType "$type"; then
            # Set proper transform
            getSwiftTypeAndTransformType $format $swift_type
        elif [ "$type" == "array" ]; then
            array_subtype="$(echo $definition_dictionary | jq -r .properties.$property.items.type)"
            array_format="$(echo $definition_dictionary | jq -r .properties.$property.items.format)"

            # Handle object subtype
            if [ "$array_subtype" == "null" ]; then
                type="$(echo $definition_dictionary | jq -r .properties.$property.items.\"\$ref\" | cut -d/ -f3)"
            fi

            if getSwiftType "$array_subtype"; then
                # Set proper transform
                getSwiftTypeAndTransformType $array_format $swift_type
                array_subtype=$swift_type
            else
                array_subtype=$type
                transform_type="none"
            fi

            swift_type="[$array_subtype]"
        else
            swift_type=$type
            transform_type="none"
        fi

        if $type_casting_enabled ; then
            # Use type casting
            transform_types+=($transform_type)
        else
            # Do not transform
            transform_types+=("none")
        fi

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

        # Append file with properties
        printf "    var $allowed_property_name: $swift_type$optional_type\n" >> "$output_filename"

        # Append init_params
        if [[ -z $init_params ]]; then
            init_params="$allowed_property_name: $swift_type? = nil"
        else
            init_params="${init_params}, $allowed_property_name: $swift_type? = nil"
        fi

        # Append init_body
        if [[ -z $init_body ]]; then
            init_body="\n        self.$allowed_property_name = $allowed_property_name\n    "
        else
            init_body="${init_body}    self.$allowed_property_name = $allowed_property_name\n    "
        fi
    done
    printf "\n" >> "$output_filename"

################################# Init #################################
    # Append init section
    printf "    init($init_params) {$init_body}\n\n" >> "$output_filename"

    if $assert_values && [[ ! -z $required_fields ]]; then
        printf "    init?(map: Map) {\n" >> "$output_filename"
        echo $required_fields | xargs -n1 -I {} printf "        guard map.assureValuePresent(forKey: \"{}\") else { return nil }\n" >> "$output_filename"
        printf "    }\n\n" >> "$output_filename"
    else
        printf "    init?(map: Map) {}\n\n" >> "$output_filename"
    fi

################################# Mapping #################################
    # Append mapping section
    printf "    mutating func mapping(map: Map) {\n" >> "$output_filename"
    index=0
    for property in $properties; do
        getAllowedPropertyName $property

        # Get map expression
        if [ "${transform_types[$index]}" == "none" ]; then
            map_expression="map[\"${property}\"]"
        else
            map_expression="(map[\"${property}\"], ${transform_types[$index]}Transform())"
        fi

        printf "        ${allowed_property_name} <- ${map_expression}\n" >> "$output_filename"
        ((index++))
    done
    printf "    }\n}\n\n" >> "$output_filename"

################################# Equatable #################################
    # Append equatable section
    printf "//-----------------------------------------------------------------------------\n" >> "$output_filename"
    printf "// MARK: - Equatable\n" >> "$output_filename"
    printf "//-----------------------------------------------------------------------------\n\n" >> "$output_filename"
    printf "extension $definition: Equatable {\n" >> "$output_filename"
    printf "    static func ==(lhs: $definition, rhs: $definition) -> Bool {\n" >> "$output_filename"
    if [[ -z $properties ]]; then
        printf "        return true\n" >> "$output_filename"
    else
        linePrefix="        return "
        for property in $properties; do
            getAllowedPropertyName $property
            printf "${linePrefix}lhs.${allowed_property_name} == rhs.${allowed_property_name}\n" >> "$output_filename"
            linePrefix="            && "
        done
    fi
    printf "    }\n" >> "$output_filename"
    printf "}\n" >> "$output_filename"

    printf " ${green_color}OK${no_color}\n"
done

################################# Done #################################
printf "\n${green_color}Done${no_color}\n\n"
