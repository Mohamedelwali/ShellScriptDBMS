#!/bin/bash
# Simple Bash DBMS
# Author: Mohamed Elwaly, and Hassan Amer
# Version: 1.0
# Date: 2025-05-30
# Description: A menu-driven mini database management system in Bash.


# Print help if requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo -e "${GREEN}Simple Bash DBMS v$VERSION${NC}"
    echo "Usage: ./ShellScriptDBMS.sh"
    echo "Follow the interactive menu prompts."
    exit 0
fi


# Trap Ctrl+C for clean exit
trap 'echo -e "\n${YELLOW}Exiting...${NC}"; exit 0' SIGINT


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Validate names: start with letter or underscore, followed by letters, digits, or underscores
is_valid_name() {
    if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 0
    else
        return 1
    fi
}


DB_DIR="./databases"
mkdir -p "$DB_DIR"


# ===== Main Menu =====
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}Welcome to the Simple DBMS${NC}"
        echo -e "${BLUE}====== DBMS Main Menu ======${NC}"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"
        read -r -p "Select an option [1-5]: " choice

        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Try again.${NC}" ;;
        esac
        read -r -p "Press Enter to continue..."
    done
}


# ===== Database Functions =====

# Create a new database
create_database() {
    read -r -p "Enter new database name: " dbname   # Use read -r to prevent backslash escapes.
    if ! is_valid_name "$dbname"; then
        echo -e "${RED}Invalid database name. Must start with a letter or underscore, followed by letters, digits, or underscores.${NC}"
        return
    fi

    if [ -d "$DB_DIR/$dbname" ]; then
        echo -e "${YELLOW}Database '$dbname' already exists.${NC}"
        return
    else
        mkdir "$DB_DIR/$dbname"
        echo -e "${GREEN}Database '$dbname' created.${NC}" 
    fi
}


# List all databases
list_databases() {
    echo "Databases:"

    # Check if the database directory exists and is not empty
    if [ -d "$DB_DIR" ]; then
        local db_count
        db_count=$(find "$DB_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l)
        # If no databases found, print a message
        if [ "$db_count" -eq 0 ]; then
            echo -e "${YELLOW}No databases found.${NC}"
        else
            # List databases, one per line, sorted
            ls -1 "$DB_DIR" | sort | while read -r db; do
                echo "  - $db"
            done
        fi
    else
        echo -e "${YELLOW}No databases found.${NC}"
    fi
}


# Connect to a database
connect_database() {
    read -r -p "Enter database name to connect: " dbname

    # Validate database name format
    if ! is_valid_name "$dbname"; then
        echo -e "${RED}Invalid database name. Use letters, digits, underscores; start with letter or underscore.${NC}"
        return
    fi
    # Check if the database exists
    if [ -d "$DB_DIR/$dbname" ]; then
        echo -e "${GREEN}Connected to '$dbname'.${NC}"
        database_menu "$dbname"
    else
        echo -e "${YELLOW}Database does not exist.${NC}"
    fi
}


# Drop a database
drop_database() {
    read -r -p "Enter database name to drop: " dbname

    # Validate database name
    if ! is_valid_name "$dbname"; then
        echo -e "${RED}Invalid database name.${NC}"
        return
    fi
    # Check if the database exists
    if [ -d "$DB_DIR/$dbname" ]; then
        read -r -p "Are you sure you want to delete database '$dbname'? This action cannot be undone. (y/n): " confirm
        # Confirm deletion
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -r "$DB_DIR/$dbname"
            echo -e "${GREEN}Database '$dbname' dropped.${NC}"
        else
            echo -e "${YELLOW}Drop database cancelled.${NC}"
        fi
    else
        echo -e "${YELLOW}Database does not exist.${NC}"
    fi
}


# ===== Database Menu =====

database_menu() {
    local dbname="$1"
    local dbpath="$DB_DIR/$dbname"

    while true; do
        clear
        echo -e "${BLUE}====== Database: $dbname ======${NC}"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Back to Main Menu"
        read -r -p "Select an option [1-8]: " choice

        case $choice in
            1) create_table "$dbpath" ;;
            2) list_tables "$dbpath" ;;
            3) drop_table "$dbpath" ;;
            4) insert_into_table "$dbpath" ;;
            5) select_from_table "$dbpath" ;;
            6) delete_from_table "$dbpath" ;;
            7) update_table "$dbpath" ;;
            8) break ;;
            *) echo -e "${RED}Invalid option. Try again.${NC}" ;;
        esac
        read -r -p "Press Enter to continue..."
    done
}


# ===== Table Functions =====

# Create a new table
create_table() {
    local dbpath="$1"
    read -r -p "Enter table name: " tname
    if ! is_valid_name "$tname"; then
        echo -e "${RED}Invalid table name.${NC}"
        return
    fi
    if [ -f "$dbpath/$tname" ]; then
        echo -e "${YELLOW}Table already exists.${NC}"
        return
    fi

    read -r -p "Enter number of columns: " ncols
    if ! [[ "$ncols" =~ ^[0-9]+$ ]] || [ "$ncols" -lt 1 ]; then
        echo -e "${RED}Invalid number.${NC}"
        return
    fi

    columns=()
    types=()
    for (( i=1; i<=ncols; i++ )); do
        while true; do
            read -r -p "Enter name for column $i: " col
            if ! is_valid_name "$col"; then
                echo -e "${RED}Invalid column name.${NC}"
            else
                if [[ " ${columns[*]} " == *" $col "* ]]; then
                    echo -e "${YELLOW}Column name already used.${NC}"
                else
                    columns+=("$col")
                    break
                fi
            fi
        done
        while true; do
            read -r -p "Enter datatype for $col (int/string): " dtype
            if [[ "$dtype" == "int" || "$dtype" == "string" ]]; then
                types+=("$dtype")
                break
            else
                echo -e "${RED}Invalid datatype. Choose 'int' or 'string'.${NC}"
            fi
        done
    done

    echo "Columns: ${columns[*]}"
    while true; do
        read -r -p "Enter primary key column: " pk
        if [[ " ${columns[*]} " == *" $pk "* ]]; then
            break
        else
            echo -e "${RED}Primary key must be one of the columns.${NC}"
        fi
    done

    {
        echo "${columns[*]}"
        echo "${types[*]}"
        echo "$pk"
    } > "$dbpath/$tname.meta"

    touch "$dbpath/$tname"
    echo -e "${GREEN}Table '$tname' created.${NC}"
}


# List all tables
list_tables() {
    local dbpath="$1"
    echo "Tables:"
    
    # Check if there are any .meta files (tables) in the database directory
    shopt -s nullglob
    local meta_files=("$dbpath"/*.meta)
    shopt -u nullglob

    if [ ${#meta_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No tables found.${NC}"
        return
    fi

    # List tables
    for file in "${meta_files[@]}"; do
        tname=$(basename "$file" .meta)
        echo "  - $tname"
    done
}


# Drop a table
drop_table() {
    local dbpath="$1"
    read -r -p "Enter table name to drop: " tname

    # Validate table name
    if ! is_valid_name "$tname"; then
        echo -e "${RED}Invalid table name.${NC}"
        return
    fi

    if [ -f "$dbpath/$tname" ] && [ -f "$dbpath/$tname.meta" ]; then
        read -r -p "Are you sure you want to delete table '$tname'? This action cannot be undone. (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm "$dbpath/$tname" "$dbpath/$tname.meta"
            echo -e "${GREEN}Table '$tname' dropped.${NC}"
        else
            echo -e "${YELLOW}Drop table cancelled.${NC}"
        fi
    else
        echo -e "${YELLOW}Table does not exist.${NC}"
    fi
}


# Insert a new row into a table
insert_into_table() {
    local dbpath="$1"
    read -r -p "Enter table name to insert into: " tname
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo -e "${RED}Table does not exist.${NC}"
        return
    fi

    # Read metadata
    IFS=' ' read -r -a columns < <(sed -n '1p' "$metafile")
    IFS=' ' read -r -a types < <(sed -n '2p' "$metafile")
    pk=$(sed -n '3p' "$metafile")

    values=()
    for i in "${!columns[@]}"; do
        col="${columns[$i]}"
        dtype="${types[$i]}"
        while true; do
            read -r -p "Enter value for $col ($dtype): " val
            # Type validation
            if [[ "$dtype" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid integer.${NC}"
            elif [[ "$dtype" == "string" && -z "$val" ]]; then
                echo -e "${RED}String cannot be empty.${NC}"
            else
                # Primary key uniqueness check
                if [ "$col" == "$pk" ]; then
                    if grep -q "^$val" "$tablefile"; then
                        echo -e "${YELLOW}Primary key value already exists.${NC}"
                        continue
                    fi
                fi
                values+=("$val")
                break
            fi
        done
    done

    # Save row (space-separated)
    echo "${values[*]}" >> "$tablefile"
    echo -e "${GREEN}Row inserted.${NC}"
}


# Select all rows from a table
select_from_table() {
    local dbpath="$1"
    read -r -p "Enter table name to select from: " tname
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo -e "${RED}Table does not exist.${NC}"
        return
    fi

    IFS=' ' read -r -a columns < <(sed -n '1p' "$metafile")

    # Print header
    printf "|"
    for col in "${columns[@]}"; do
        printf " %-15s |" "$col"
    done
    echo
    printf "%0.s-" $(seq 1 $((18 * ${#columns[@]}))); echo

    # Print rows
    if [ ! -s "$tablefile" ]; then
        echo -e "${YELLOW}No data.${NC}"
        return
    fi

    while read -r line; do
        IFS=' ' read -r -a fields <<< "$line"
        printf "|"
        for field in "${fields[@]}"; do
            printf " %-15s |" "$field"
        done
        echo
    done < "$tablefile"
}


# Delete a row from a table
delete_from_table() {
    local dbpath="$1"
    read -r -p "Enter table name to delete from: " tname
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo -e "${RED}Table does not exist.${NC}"
        return
    fi

    IFS=' ' read -r -a columns < <(sed -n '1p' "$metafile")
    pk=$(sed -n '3p' "$metafile")

    # Find index of primary key column
    local pk_index=-1
    for i in "${!columns[@]}"; do
        if [ "${columns[$i]}" == "$pk" ]; then
            pk_index=$i
            break
        fi
    done

    if [ $pk_index -eq -1 ]; then
        echo -e "${RED}Primary key not found in columns.${NC}"
        return
    fi

    read -r -p "Enter $pk value to delete: " pk_val

    # Check if row exists
    if ! grep -q "^$pk_val" "$tablefile"; then
        echo -e "${YELLOW}No row found with $pk = $pk_val.${NC}"
        return
    fi

    # Confirm deletion
    read -r -p "Are you sure you want to delete the row with $pk = $pk_val? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deletion cancelled.${NC}"
        return
    fi

    # Delete the row
    grep -v "^$pk_val" "$tablefile" > "$tablefile.tmp" && mv "$tablefile.tmp" "$tablefile"
    echo -e "${GREEN}Row with $pk = $pk_val deleted.${NC}"
}


# Update a row in a table
update_table() {
    local dbpath="$1"
    read -r -p "Enter table name to update: " tname
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo -e "${RED}Table does not exist.${NC}"
        return
    fi

    IFS=' ' read -r -a columns < <(sed -n '1p' "$metafile")
    IFS=' ' read -r -a types < <(sed -n '2p' "$metafile")
    pk=$(sed -n '3p' "$metafile")

    # Find index of primary key column
    local pk_index=-1
    for i in "${!columns[@]}"; do
        if [ "${columns[$i]}" == "$pk" ]; then
            pk_index=$i
            break
        fi
    done

    if [ $pk_index -eq -1 ]; then
        echo -e "${RED}Primary key not found.${NC}"
        return
    fi

    read -r -p "Enter $pk value of row to update: " pk_val

    # Find the row
    local old_row
    old_row=$(grep "^$pk_val" "$tablefile")
    if [ -z "$old_row" ]; then
        echo -e "${YELLOW}No row found with $pk = $pk_val.${NC}"
        return
    fi

    IFS=' ' read -r -a old_values <<< "$old_row"
    new_values=()

    for i in "${!columns[@]}"; do
        col="${columns[$i]}"
        dtype="${types[$i]}"
        old_val="${old_values[$i]}"
        while true; do
            read -r -p "Enter new value for $col ($dtype) [old: $old_val]: " val
            # If empty input, keep old value
            if [ -z "$val" ]; then
                val="$old_val"
            fi
            # Validate type
            if [[ "$dtype" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid integer.${NC}"
            elif [[ "$dtype" == "string" && -z "$val" ]]; then
                echo -e "${RED}String cannot be empty.${NC}"
            else
                # If primary key changed, check uniqueness
                if [ "$col" == "$pk" ] && [ "$val" != "$old_val" ]; then
                    if grep -q "^$val" "$tablefile"; then
                        echo -e "${YELLOW}Primary key value already exists.${NC}"
                        continue
                    fi
                fi
                new_values+=("$val")
                break
            fi
        done
    done

    echo
    echo "Old row: $old_row"
    echo "New row: ${new_values[*]}"
    read -r -p "Confirm update? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Update cancelled.${NC}"
        return
    fi

    # Replace old row with new row
    grep -v "^$pk_val" "$tablefile" > "$tablefile.tmp"
    echo "${new_values[*]}" >> "$tablefile.tmp"
    mv "$tablefile.tmp" "$tablefile"

    echo -e "${GREEN}Row updated successfully.${NC}"
}


# ===== Start the main menu =====
main_menu