#!/bin/bash     (Shebang line use to explain the language of the script is bash)

DB_DIR="./databases"

# Ensure databases directory exists
mkdir -p "$DB_DIR"

# Validate names: start with letter or underscore, followed by letters, digits, or underscores
is_valid_name() {
    if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 0
    else
        return 1
    fi
}

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
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo "Table does not exist."
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
            read -p "Enter value for $col ($dtype): " val
            # Type validation
            if [[ "$dtype" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
                echo "Invalid integer."
            elif [[ "$dtype" == "string" && -z "$val" ]]; then
                echo "String cannot be empty."
            else
                # Primary key uniqueness check
                if [ "$col" == "$pk" ]; then
                    if grep -q "^$val" "$tablefile"; then
                        echo "Primary key value already exists."
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
    echo "Row inserted."
}

select_from_table() {
    local dbpath="$1"
    read -p "Enter table name to select from: " tname
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo "Table does not exist."
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
        echo "No data."
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

delete_from_table() {
    local dbpath="$1"
    read -p "Enter table name to delete from: " tname
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo "Table does not exist."
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
        echo "Primary key not found in columns."
        return
    fi

    read -p "Enter $pk value to delete: " pk_val

    # Check if row exists
    if ! grep -q "^$pk_val" "$tablefile"; then
        echo "No row found with $pk = $pk_val"
        return
    fi

    # Delete the row
    grep -v "^$pk_val" "$tablefile" > "$tablefile.tmp" && mv "$tablefile.tmp" "$tablefile"
    echo "Row with $pk = $pk_val deleted."
}

update_table() {
    local dbpath="$1"
    read -p "Enter table name to update: " tname
    local metafile="$dbpath/$tname.meta"
    local tablefile="$dbpath/$tname"

    if [ ! -f "$metafile" ]; then
        echo "Table does not exist."
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
        echo "Primary key not found."
        return
    fi

    read -p "Enter $pk value of row to update: " pk_val

    # Find the row
    local old_row
    old_row=$(grep "^$pk_val" "$tablefile")
    if [ -z "$old_row" ]; then
        echo "No row found with $pk = $pk_val"
        return
    fi

    IFS=' ' read -r -a old_values <<< "$old_row"
    new_values=()

    for i in "${!columns[@]}"; do
        col="${columns[$i]}"
        dtype="${types[$i]}"
        old_val="${old_values[$i]}"
        while true; do
            read -p "Enter new value for $col ($dtype) [old: $old_val]: " val
            # If empty input, keep old value
            if [ -z "$val" ]; then
                val="$old_val"
            fi
            # Validate type
            if [[ "$dtype" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
                echo "Invalid integer."
            elif [[ "$dtype" == "string" && -z "$val" ]]; then
                echo "String cannot be empty."
            else
                # If primary key changed, check uniqueness
                if [ "$col" == "$pk" ] && [ "$val" != "$old_val" ]; then
                    if grep -q "^$val" "$tablefile"; then
                        echo "Primary key value already exists."
                        continue
                    fi
                fi
                new_values+=("$val")
                break
            fi
        done
    done

    # Replace old row with new row
    grep -v "^$pk_val" "$tablefile" > "$tablefile.tmp"
    echo "${new_values[*]}" >> "$tablefile.tmp"
    mv "$tablefile.tmp" "$tablefile"
    echo "Row updated."
}

main_menu



