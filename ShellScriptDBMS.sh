#!/bin/bash
# Simple Bash DBMS
# Author: Mohamed Elwaly, and Hassan Amer
# Version: 1.0
# Date: 2025-05-30
# Description: A menu-driven mini database management system in Bash.


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
SKYBLUE='\033[0;36m'
NC='\033[0m' # No Color


# Trap Ctrl+C for clean exit
trap 'echo -e "\n${YELLOW}Exiting...${NC}"; exit 0' SIGINT


# Function to print help message
print_help() {
    echo
    echo -e "${GREEN}Simple Bash DBMS $VERSION${NC}"
    echo
    echo -e "${YELLOW}Usage:${NC} ${BLUE}./ShellScriptDBMS.sh [OPTIONS]${NC}"
    echo
    echo -e "${YELLOW}Options:${NC} ${BLUE}-h, --help      Show this help message and exit.${NC}"
    echo
    echo -e "${PURPLE}Run the script without options to start the interactive menu.${NC}"
    echo
    echo -e "${YELLOW}Description:${NC}"
    echo -e "  ${SKYBLUE}A menu-driven mini database management system implemented in Bash.${NC}"
    echo -e "  ${SKYBLUE}Supports creating, listing, connecting, and dropping databases and tables,${NC}"
    echo -e "  ${SKYBLUE}as well as inserting, selecting, updating, and deleting table data.${NC}"
    echo
}

# Check if the script is run with root privileges
VERSION="Version 1.0"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    print_help
    exit 0
fi


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

    echo -e "${BLUE}Columns: ${columns[*]}${NC}"
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

<<<<<<< HEAD
insert_into_table() {
    local dbpath="$1"
    read -p "Enter table name to insert into: " tname

    if [ ! -f "$dbpath/$tname" ] || [ ! -f "$dbpath/$tname.meta" ]; then
        echo "Table or metadata does not exist."
        return
    fi

    # Reading metadata
    IFS=' ' read -r -a columns < "$dbpath/$tname.meta"
    IFS=' ' read -r -a types < <(sed -n '2p' "$dbpath/$tname.meta")
    pk=$(sed -n '3p' "$dbpath/$tname.meta")

    # Finding pkey index
    pk_index=-1
    for i in "${!columns[@]}"; do
        if [ "${columns[$i]}" == "$pk" ]; then
            pk_index=$i
            break
        fi
    done

    if [ $pk_index -eq -1 ]; then
        echo "Primary key not found in columns."
        return
    fi

    # Collect values from user
=======

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

>>>>>>> Elwaly
    values=()
    for i in "${!columns[@]}"; do
        col="${columns[$i]}"
        dtype="${types[$i]}"
<<<<<<< HEAD

        while true; do
            read -p "Enter value for $col ($dtype): " val

            # Simple datatype validation
            if [ "$dtype" == "int" ]; then
                if ! [[ "$val" =~ ^-?[0-9]+$ ]]; then
                    echo "Invalid integer. Try again."
                    continue
                fi
            fi

            # Check primary key uniqueness
            if [ $i -eq $pk_index ]; then
                if grep -q "^$val" "$dbpath/$tname"; then
                    echo "Primary key value '$val' already exists. Try again."
                    continue
                fi
            fi

            values+=("$val")
            break
        done
    done

    record=$(IFS='|'; echo "${values[*]}")

    # Append to table file
    echo "$record" >> "$dbpath/$tname"
    echo "Record inserted into table '$tname'."
}
select_from_table() {
    local dbpath="$1"
    read -p "Enter table name to select from: " tname

    if [ ! -f "$dbpath/$tname" ]; then
        echo "Table does not exist."
        return
    fi

    IFS=' ' read -r -a columns < "$dbpath/$tname.meta"
    pk=$(sed -n '3p' "$dbpath/$tname.meta")

    pk_index=-1
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$pk" ]]; then
            pk_index=$i
            break
        fi
    done

    echo "Select Options:"
    echo "1. View all records"
    echo "2. View a record by $pk"
    read -p "Choose [1-2]: " opt

    case $opt in
        1)
            echo "====== All Records in $tname ======"
            echo "${columns[*]}"
            cat "$dbpath/$tname"
            ;;
        2)
            read -p "Enter $pk value: " pk_val
            echo "${columns[*]}"
            awk -F'|' -v pk_idx=$((pk_index+1)) -v pk_val="$pk_val" '$pk_idx == pk_val { print }' "$dbpath/$tname"
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

delete_from_table() {
    local dbpath="$1"
    read -p "Enter table name to delete from: " tname
    if [ ! -f "$dbpath/$tname" ]; then
        echo "Table does not exist."
        return
    fi

    IFS=' ' read -r -a columns < "$dbpath/$tname.meta"
    IFS=' ' read -r -a types < <(sed -n '2p' "$dbpath/$tname.meta")
    pk=$(sed -n '3p' "$dbpath/$tname.meta")

    read -p "Enter primary key value to delete record: " pk_val
    if [ -z "$pk_val" ]; then
        echo "Primary key value cannot be empty."
        return
    fi

    # Find primary key index
    local pk_index=-1
    for i in "${!columns[@]}"; do
        if [ "${columns[$i]}" == "$pk" ]; then
            pk_index=$i
            break
        fi
    done
    if [ $pk_index -eq -1 ]; then
        echo "Primary key column not found."
        return
    fi

awk -F'|' -v pk_idx=$((pk_index+1)) -v pk_val="$pk_val" 'BEGIN{OFS=FS} $pk_idx != pk_val' "$dbpath/$tname" > "$dbpath/$tname.tmp" && mv "$dbpath/$tname.tmp" "$dbpath/$tname"
echo "Record(s) with $pk=$pk_val deleted."
}


update_table() {

    local dbpath="$1"
    read -p "Enter table name to update: " tname

    if [ ! -f "$dbpath/$tname" ]; then
        echo "Table does not exist."
        return
    fi

    
    IFS=' ' read -r -a columns < "$dbpath/$tname.meta"
    IFS=' ' read -r -a types < <(sed -n '2p' "$dbpath/$tname.meta")
    pk=$(sed -n '3p' "$dbpath/$tname.meta")

    
    pk_index=-1
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$pk" ]]; then
            pk_index=$i
            break
        fi
    done

    if [ "$pk_index" -eq -1 ]; then
        echo "Primary key not found in metadata."
        return
    fi

    read -p "Enter value of $pk to update: " pk_val

    
    match_line=$(awk -F'|' -v pk_idx=$((pk_index+1)) -v pk_val="$pk_val" '$pk_idx == pk_val {print NR}' "$dbpath/$tname")
    if [ -z "$match_line" ]; then
        echo "No record found with $pk = $pk_val"
        return
    fi

    echo "Updating record with $pk = $pk_val"

    new_record=()
    for i in "${!columns[@]}"; do
        col="${columns[$i]}"
        dtype="${types[$i]}"

        if [[ "$col" == "$pk" ]]; then
            new_record+=("$pk_val")  # Don't update primary key
            continue
        fi

        read -p "Enter new value for $col ($dtype): " val

        # Type check
        if [[ "$dtype" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
            echo "Invalid int value for $col"
            return
        fi

        new_record+=("$val")
    done

   
    IFS='|' updated_line="${new_record[*]}"

    
    awk -v ln="$match_line" -v newline="$updated_line" 'NR == ln {$0 = newline} {print}' "$dbpath/$tname" > "$dbpath/$tname.tmp" && mv "$dbpath/$tname.tmp" "$dbpath/$tname"

    echo "Record updated successfully."
}



main_menu

=======
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
>>>>>>> Elwaly
