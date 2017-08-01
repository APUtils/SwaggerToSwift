#!/bin/bash

#
#  makeModels.command
#  SwaggerToSwift
#
#  Created by Anton Plebanovich on 7/31/17.
#  Copyright © 2017 Anton Plebanovich. All rights reserved.
#

# This script converts swagger.json file into Swift models
# Usage: makeModel.command [swagger json file]
# Or place `swagger.json` file in same folder and run

# Configuration Constants
type_casting_enabled=true # Enable type casting?
describable_enabled=true # Add Describable protocol conformance?
assert_values=true # Add value assertion checks? Only asserts mandatory values.
project_name="<#PROJECT_NAME#>" # Project name for header
company_name="<#COMPANY_NAME#>" # Company name for header

# Colors Constants
red_color='\033[0;31m'
green_color='\033[0;32m'
blue_color='\033[0;34m'
no_color='\033[0m'

# Helper Functions
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

# Requires `jq` installed - https://stedolan.github.io/jq/download/
# brew install jq

hash jq 2>/dev/null || { printf >&2 "\n${red_color}Requires jq installed - https://stedolan.github.io/jq/download/${no_color}\n\n"; exit 1; }

# Type casting note
if $type_casting_enabled || $assert_values ; then
    printf "\n${blue_color}Type casting and values assertion requires ObjectMapperAdditions framework installed - https://github.com/APUtils/ObjectMapperAdditions${no_color}\n\n"
fi

# Describable note
if $describable_enabled ; then
    printf "\n${blue_color}Describable protocol requires APExtensions framework installed - https://github.com/APUtils/APExtensions${no_color}\n\n"
fi

# Source file
if [[ -z "$1" && ! -z "swagger.json" ]]; then
    source_filename="swagger.json"
elif [[ -f $1 ]]; then
    source_filename=$1
elif [[ -f "$1.json" ]]; then
    source_filename="$1.json"
else
    echo "ERROR! File not found"
    exit 1
fi
printf "Parsing ${source_filename}...\n"

# Directories routine
base_dir=$(dirname "$0")
cd "$base_dir"

output_dir="${base_dir}/Models/"
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
    output_filename="${output_dir}${definition}.swift"
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

    user_name="$(echo $USER || git config user.name)"
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

    transform_types=()
    for property in $properties; do
        # Swagger type
        type="$(echo $definition_dictionary | jq -r .properties.$property.type)"

        # Handle object type
        if [ "$type" == "null" ]; then
            type="$(echo $definition_dictionary | jq -r .properties.$property.\"\$ref\" | cut -d/ -f3)"
        fi

        # Swift type
        if getSwiftType "$type"; then
            transform_type="$swift_type"
        elif [ "$type" == "array" ]; then
            array_subtype="$(echo $definition_dictionary | jq -r .properties.$property.items.type)"

            # Handle object subtype
            if [ "$array_subtype" == "null" ]; then
                type="$(echo $definition_dictionary | jq -r .properties.$property.items.\"\$ref\" | cut -d/ -f3)"
            fi

            if getSwiftType "$array_subtype"; then
                array_subtype=$swift_type
                transform_type="$array_subtype"
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

        # Appen file with properties
        printf "    var $property: $swift_type$optional_type\n" >> "$output_filename"
    done
    printf "\n" >> "$output_filename"

################################# Init #################################
    # Append init section
    printf "    init() {}\n\n" >> "$output_filename"

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
        # Get map expression
        if [ "${transform_types[$index]}" == "none" ]; then
            map_expression="map[\"${property}\"]"
        else
            map_expression="(map[\"${property}\"], ${transform_types[$index]}Transform())"
        fi

        printf "        ${property} <- ${map_expression}\n" >> "$output_filename"
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
            printf "${linePrefix}lhs.${property} == rhs.${property}\n" >> "$output_filename"
            linePrefix="            && "
        done
    fi
    printf "    }\n" >> "$output_filename"
    printf "}\n" >> "$output_filename"

    printf " ${green_color}OK${no_color}\n"
done

################################# Done #################################
printf "\n${green_color}Done${no_color}\n\n"
