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



main_menu



