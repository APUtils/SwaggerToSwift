#!/bin/sh

# This script converts swagger.json file into Swift models
# Usage: makeModel.command [swagger json file]
# Or place `swagger.json` file in same folder and run

# Configuration Constants
type_casting_enabled=true

# Colors Constants
red_color='\033[0;31m'
green_color='\033[0;32m'
yellow_color='\033[0;33m'
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

hash jq 2>/dev/null || { printf >&2 "${red_color}Requires jq installed - https://stedolan.github.io/jq/download/${no_color}\n"; exit 1; }

# Type casting warning
if $type_casting_enabled ; then
    printf "${yellow_color}Type casting requires ObjectMapperTypeCast pod installed - https://github.com/APUtils/ObjectMapperTypeCast${no_color}\n"
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

base_dir=$(dirname "$0")
cd "$base_dir"

output_dir="${base_dir}/_Models/"
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

    # Creating file with header and imports
    user_name="$(echo $USER || git config user.name)"
    printf "//\n//  $definition.swift\n//  <#PROJECT_NAME#>\n//\n//  Created by $user_name on $(date +'%m/%d/%y').\n//  Copyright © $(date +'%Y') $user_name. All rights reserved.\n//\n\nimport ObjectMapper\n\n\n" > "$output_filename"

    # properties
    properties="$(echo $definition_dictionary | jq -r '.properties | keys | .[]')"

    # Append file with struct declaration
    printf "struct $definition: Mappable {\n" >> "$output_filename"

    # Get required fields if they exist
    if [ "$(echo $definition_dictionary | jq -r 'has("required")')" == "true" ]; then
        required_fields="$(echo $definition_dictionary | jq -r '.required | .[]')"
    fi

    map_operators=()
    for property in $properties; do
        # Swagger type
        type="$(echo $definition_dictionary | jq -r .properties.$property.type)"

        # Handle object type
        if [ "$type" == "null" ]; then
            type="$(echo $definition_dictionary | jq -r .properties.$property.\"\$ref\" | cut -d/ -f3)"
        fi

        # Swift type
        if getSwiftType "$type"; then
            map_operator="<--"
        elif [ "$type" == "array" ]; then
            array_subtype="$(echo $definition_dictionary | jq -r .properties.$property.items.type)"

            # Handle object subtype
            if [ "$array_subtype" == "null" ]; then
                type="$(echo $definition_dictionary | jq -r .properties.$property.items.\"\$ref\" | cut -d/ -f3)"
            fi

            if getSwiftType "$array_subtype"; then
                array_subtype=$swift_type
            else
                array_subtype=$type
            fi

            swift_type="[$array_subtype]"
            map_operator="<-"
        else
            swift_type=$type
            map_operator="<-"
        fi

        if $type_casting_enabled ; then
            # Use type casting
            map_operators+=($map_operator)
        else
            # Use default map operator
            map_operators+=("<-")
        fi


        # Getting optionality type
        optional_type="?"
        for required_field in $required_fields; do
            if [[ "${property}" == "${required_field}" ]]; then
                optional_type="!"
                break
            fi
        done

        # Appen file with properties
        printf "    var $property: $swift_type$optional_type\n" >> "$output_filename"
    done
    printf "\n" >> "$output_filename"

    # Append init section
    printf "    init() {}\n\n" >> "$output_filename"
    printf "    init?(map: Map) {}\n\n" >> "$output_filename"

    # Append mapping section
    printf "    mutating func mapping(map: Map) {\n" >> "$output_filename"
    index=0
    for property in $properties; do
        printf "        ${property} ${map_operators[$index]} map[\"${property}\"]\n" >> "$output_filename"
        ((index++))
    done
    printf "    }\n}\n\n" >> "$output_filename"

    # Append equatable section
    printf "//-----------------------------------------------------------------------------\n" >> "$output_filename"
    printf "// MARK: - Equatable\n" >> "$output_filename"
    printf "//-----------------------------------------------------------------------------\n\n" >> "$output_filename"
    printf "extension $definition: Equatable {\n" >> "$output_filename"
    printf "    static func ==(lhs: $definition, rhs: $definition) -> Bool {\n" >> "$output_filename"
    linePrefix="        return "
    for property in $properties; do
        printf "${linePrefix}lhs.${property} == rhs.${property}\n" >> "$output_filename"
        linePrefix="            && "
    done
    printf "    }\n" >> "$output_filename"
    printf "}\n" >> "$output_filename"

    printf " OK\n"
done

printf "${green_color}Done${no_color}\n"
