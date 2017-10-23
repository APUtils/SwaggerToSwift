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
    echo -e "Swagger JSON spec to Swift ObjectMapper models converter"
    echo -e ""
    echo -e "./makeModels.sh"
    echo -e "    -h    --help                    Show help"
    echo -e "    -f    --file                    Swagger spec JSON file name. Default - 'swagger.json'."
    echo -e "    -o    --output-dir              Models output directory. Default - same as script file location."
    echo -e "    -mp   --model-prefix            Models prefix. Default - no prefix."
    echo -e "    -t    --type-casting-enabled    Enable type casting? Default - true."
    echo -e "    -mn   --model-name              Specify concrete model name to parse."
    echo -e "    -de   --describable-enabled     Add Describable protocol conformance? Default - true."
    echo -e "    -a    --assert-values           Add value assertion checks? Only asserts mandatory values. Default - true."
    echo -e "    -p    --project-name            Project name for header. Default - <#PROJECT_NAME#>."
    echo -e "    -u    --user-name               Company name for header. Default - \$USER or git user name."
    echo -e "    -c    --company-name            Company name for header. Default - <#COMPANY_NAME#>."
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
        -mp | --model-prefix)
            model_prefix=$VALUE
            shift 2
            ;;
        -t | --type-casting-enabled)
            assertBoolParam $VALUE
            type_casting_enabled=$VALUE
            shift 2
            ;;
        -mn | --model-name)
            model_name=$VALUE
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
    if [[ $describable_enabled == true && "$1" == "description" ]]; then
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
    elif [ $1 == "url" ]; then
        swift_type="URL"
        transform_type="URL"
    else
        swift_type=$2
        transform_type=$2
    fi
}

# $1 - model name
# $2 - model dictionary
parseModel() {
    local loc_model_name=$1 #$definition
    local loc_model_dictionary=$2 #$definition_dictionary

    # Creating models only for objects
    if [ "$(echo $loc_model_dictionary | jq -r .type)" != "object" ]; then
        continue
    fi

    # Output file
    local loc_output_filename="${output_dir}/${loc_model_name}.swift"

    printf "Generating '${loc_model_name}.swift' model..."

################################# Header and Imports #################################
    # Creating file with header and imports
    local loc_imports_string="import Foundation\n"

    if $describable_enabled ; then
        loc_imports_string="${loc_imports_string}import APExtensions\n"
    fi

    loc_imports_string="${loc_imports_string}import ObjectMapper\n"

    if $type_casting_enabled || $assert_values ; then
        loc_imports_string="${loc_imports_string}import ObjectMapperAdditions\n"
    fi

    printf "//\n//  ${loc_model_name}.swift\n//  $project_name\n//\n//  Created by $user_name on $(date +'%m/%d/%y').\n//  Copyright © $(date +'%Y') $company_name. All rights reserved.\n//\n\n${loc_imports_string}\n\n" > "$loc_output_filename"

################################# Properties #################################
    # properties
    local loc_properties="$(echo $loc_model_dictionary | jq -r '.properties | keys_unsorted | .[]')"

    # Append file with struct declaration
    if $describable_enabled ; then
        local loc_protocols_string="Mappable, Describable"
    else
        local loc_protocols_string="Mappable"
    fi
    printf "struct $loc_model_name: $loc_protocols_string {\n" >> "$loc_output_filename"

    # Get required fields if they exist
    if [ "$(echo $loc_model_dictionary | jq -r 'has("required")')" == "true" ]; then
        local loc_required_fields="$(echo $loc_model_dictionary | jq -r '.required | .[]')"
    else
        local loc_required_fields=""
    fi

    local loc_init_params=""
    local loc_init_body=""

    local loc_transform_types=()
    local loc_property
    for loc_property in $loc_properties; do
        getAllowedPropertyName $loc_property
        local loc_allowed_property_name=$allowed_property_name
        # Swagger type
        local loc_type="$(echo $loc_model_dictionary | jq -r .properties.${loc_property}.type)"

        # Swagger format
        local loc_format="$(echo $loc_model_dictionary | jq -r .properties.${loc_property}.format)"

        # Handle object type
        if [ "$loc_type" == "null" ]; then
            # Get object name from refference
            loc_type="$(echo $loc_model_dictionary | jq -r .properties.${loc_property}.\"\$ref\" | cut -d/ -f3)"
            # Append prefix
            loc_type="${model_prefix}${loc_type}"
        elif [ "$loc_type" == "object" ]; then
            # Parse inner model type
            local loc_capitalized_property_name="$(tr '[:lower:]' '[:upper:]' <<< ${loc_property:0:1})${loc_property:1}"
            local loc_inner_type_dictionary="$(echo $loc_model_dictionary | jq -r .properties.${loc_property})"
            loc_type="${loc_model_name}${loc_capitalized_property_name}"
            parseModel "${loc_type}" "${loc_inner_type_dictionary}"
        fi

        # Swift type
        local loc_swift_type
        local loc_transform_type
        if getSwiftType "$loc_type"; then
            loc_swift_type=$swift_type

            # Set proper transform
            getSwiftTypeAndTransformType $loc_format $loc_swift_type
            loc_swift_type=$swift_type
            loc_transform_type=$transform_type
        elif [ "$loc_type" == "array" ]; then
            local loc_array_items="$(echo $loc_model_dictionary | jq -r .properties.${loc_property}.items)"
            local loc_array_subtype="$(echo $loc_array_items | jq -r .type)"
            local loc_array_format="$(echo $loc_array_items | jq -r .format)"

            # Handle object subtype
            if [ "$loc_array_subtype" == "null" ]; then
                # Get object name from refference
                loc_type="$(echo $loc_model_dictionary | jq -r .properties.${loc_property}.items.\"\$ref\" | cut -d/ -f3)"
                # Append prefix
                loc_type="${model_prefix}${loc_type}"
            elif [ "$loc_array_subtype" == "object" ]; then
                # Parse inner model type
                local loc_capitalized_array_property_name="$(tr '[:lower:]' '[:upper:]' <<< ${loc_property:0:1})${loc_property:1}"
                loc_type="${loc_model_name}${loc_capitalized_array_property_name}"
                parseModel "${loc_type}" "${loc_array_items}"
            fi

            if getSwiftType "$loc_array_subtype"; then
                loc_swift_type=$swift_type

                # Set proper transform
                getSwiftTypeAndTransformType $loc_array_format $loc_swift_type
                loc_swift_type=$swift_type
                loc_transform_type=$transform_type

                loc_array_subtype=$loc_swift_type
            else
                loc_array_subtype=$loc_type
                loc_transform_type="none"
            fi

            loc_swift_type="[$loc_array_subtype]"
        else
            loc_swift_type=$loc_type
            loc_transform_type="none"
        fi

        if $type_casting_enabled ; then
            # Use type casting
            loc_transform_types+=($loc_transform_type)
        else
            # Do not transform
            loc_transform_types+=("none")
        fi

        # Getting optionality type
        local loc_optional_type="?"
        if $assert_values; then
            local loc_required_field
            for loc_required_field in $loc_required_fields; do
                if [[ "${loc_property}" == "${loc_required_field}" ]]; then
                    loc_optional_type="!"
                    break
                fi
            done
        fi

        # Append file with properties
        printf "    var $loc_allowed_property_name: $loc_swift_type${loc_optional_type}\n" >> "$loc_output_filename"

        # Append loc_init_params
        if [[ -z $loc_init_params ]]; then
            loc_init_params="$loc_allowed_property_name: $loc_swift_type? = nil"
        else
            loc_init_params="${loc_init_params}, $loc_allowed_property_name: $loc_swift_type? = nil"
        fi

        # Append loc_init_body
        if [[ -z $loc_init_body ]]; then
            loc_init_body="\n        self.$loc_allowed_property_name = $loc_allowed_property_name\n    "
        else
            loc_init_body="${loc_init_body}    self.$loc_allowed_property_name = $loc_allowed_property_name\n    "
        fi
    done
    printf "\n" >> "$loc_output_filename"

################################# Init #################################
    # Append init section
    printf "    init($loc_init_params) {$loc_init_body}\n\n" >> "$loc_output_filename"

    if $assert_values && [[ ! -z $loc_required_fields ]]; then
        printf "    init?(map: Map) {\n" >> "$loc_output_filename"
        echo $loc_required_fields | xargs -n1 -I {} printf "        guard map.assureValuePresent(forKey: \"{}\") else { return nil }\n" >> "$loc_output_filename"
        printf "    }\n\n" >> "$loc_output_filename"
    else
        printf "    init?(map: Map) {}\n\n" >> "$loc_output_filename"
    fi

################################# Mapping #################################
    # Append mapping section
    printf "    mutating func mapping(map: Map) {\n" >> "$loc_output_filename"
    local loc_index=0
    local loc_property
    for loc_property in $loc_properties; do
        getAllowedPropertyName $loc_property
        local loc_allowed_property_name=$allowed_property_name

        # Get map expression
        local loc_map_expression
        if [ "${loc_transform_types[$loc_index]}" == "none" ]; then
            loc_map_expression="map[\"${loc_property}\"]"
        else
            loc_map_expression="(map[\"${loc_property}\"], ${loc_transform_types[$loc_index]}Transform())"
        fi

        printf "        ${loc_allowed_property_name} <- ${loc_map_expression}\n" >> "$loc_output_filename"
        ((loc_index++))
    done
    printf "    }\n}\n\n" >> "$loc_output_filename"

################################# Equatable #################################
    # Append equatable section
    printf "//-----------------------------------------------------------------------------\n" >> "$loc_output_filename"
    printf "// MARK: - Equatable\n" >> "$loc_output_filename"
    printf "//-----------------------------------------------------------------------------\n\n" >> "$loc_output_filename"
    printf "extension $loc_model_name: Equatable {\n" >> "$loc_output_filename"
    printf "    static func ==(lhs: $loc_model_name, rhs: $loc_model_name) -> Bool {\n" >> "$loc_output_filename"
    if [[ -z $loc_properties ]]; then
        printf "        return true\n" >> "$loc_output_filename"
    else
        local loc_linePrefix="        return "
        local loc_property
        local loc_allowed_property_name
        for loc_property in $loc_properties; do
            getAllowedPropertyName $loc_property
            loc_allowed_property_name=$allowed_property_name

            printf "${loc_linePrefix}lhs.${loc_allowed_property_name} == rhs.${loc_allowed_property_name}\n" >> "$loc_output_filename"
            loc_linePrefix="            && "
        done
    fi
    printf "    }\n" >> "$loc_output_filename"
    printf "}\n" >> "$loc_output_filename"
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
    # Only parse specified model if name passed
    if [[ ! -z $model_name && $model_name != $definition ]]; then
        continue
    fi

    # Definition dictionary
    definition_dictionary="$(echo $definitions_dictionary | jq -r .$definition)"

    # Parse model
    parseModel "${model_prefix}${definition}" "${definition_dictionary}"

    printf " ${green_color}OK${no_color}\n"
done

################################# Done #################################
printf "\n${green_color}Done${no_color}\n\n"
