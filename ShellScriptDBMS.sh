#!/bin/bash

DB_DIR="./databases"

# Ensure databases directory exists
mkdir -p "$DB_DIR"

main_menu() {
    while true; do
        echo "====== DBMS Main Menu ======"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"
        read -p "Select an option [1-5]: " choice

        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Try again." ;;
        esac
    done
}

create_database() {
    read -p "Enter new database name: " dbname
    if [ -z "$dbname" ]; then
        echo "Database name cannot be empty."
    elif [ -d "$DB_DIR/$dbname" ]; then
        echo "Database already exists."
    else
        mkdir "$DB_DIR/$dbname"
        echo "Database '$dbname' created."
    fi
}

list_databases() {
    echo "Databases:"
    ls "$DB_DIR"
}

connect_database() {
    read -p "Enter database name to connect: " dbname
    if [ -d "$DB_DIR/$dbname" ]; then
        echo "Connected to '$dbname'."
        # Call the database menu here
        database_menu "$dbname"
    else
        echo "Database does not exist."
    fi
}

drop_database() {
    read -p "Enter database name to drop: " dbname
    if [ -d "$DB_DIR/$dbname" ]; then
        rm -r "$DB_DIR/$dbname"
        echo "Database '$dbname' dropped."
    else
        echo "Database does not exist."
    fi
}


database_menu() {
    local dbname="$1"
    local dbpath="$DB_DIR/$dbname"

    while true; do
        echo "====== Database: $dbname ======"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Back to Main Menu"
        read -p "Select an option [1-8]: " choice

        case $choice in
            1) create_table "$dbpath" ;;
            2) list_tables "$dbpath" ;;
            3) drop_table "$dbpath" ;;
            4) insert_into_table "$dbpath" ;;
            5) select_from_table "$dbpath" ;;
            6) delete_from_table "$dbpath" ;;
            7) update_table "$dbpath" ;;
            8) break ;;
            *) echo "Invalid option. Try again." ;;
        esac
    done
}

create_table() {
    local dbpath="$1"
    read -p "Enter table name: " tname

    if [ -f "$dbpath/$tname" ]; then
        echo "Table already exists."
        return
    fi

    read -p "Enter number of columns: " ncols
    if ! [[ "$ncols" =~ ^[0-9]+$ ]] || [ "$ncols" -lt 1 ]; then
        echo "Invalid number."
        return
    fi

    columns=()
    types=()
    for (( i=1; i<=$ncols; i++ )); do
        read -p "Enter name for column $i: " col
        columns+=("$col")
        read -p "Enter datatype for $col (int/string): " dtype
        types+=("$dtype")
    done

    # Choose primary key
    echo "Columns: ${columns[*]}"
    read -p "Enter primary key column: " pk
    if [[ ! " ${columns[@]} " =~ " $pk " ]]; then
        echo "Invalid primary key."
        return
    fi

    # Write metadata
    {
        echo "${columns[*]}"
        echo "${types[*]}"
        echo "$pk"
    } > "$dbpath/$tname.meta"

    # Create empty table file
    touch "$dbpath/$tname"
    echo "Table '$tname' created."
}

list_tables() {
    local dbpath="$1"
    echo "Tables:"
    for file in "$dbpath"/*.meta; do
        [ -e "$file" ] || { echo "No tables found."; return; }
        tname=$(basename "$file" .meta)
        echo "- $tname"
    done
}

drop_table() {
    local dbpath="$1"
    read -p "Enter table name to drop: " tname
    if [ -f "$dbpath/$tname" ]; then
        rm "$dbpath/$tname" "$dbpath/$tname.meta"
        echo "Table '$tname' dropped."
    else
        echo "Table does not exist."
    fi
}

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
    values=()
    for i in "${!columns[@]}"; do
        col="${columns[$i]}"
        dtype="${types[$i]}"

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


main_menu



