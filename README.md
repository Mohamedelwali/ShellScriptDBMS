# 🐚 Simple Bash DBMS

A menu-driven mini Database Management System (DBMS) written in Bash.  
**Authors:** Mohamed Elwaly, Hassan Amer  
**Version:** 1.0  
**Date:** 2025-05-30

---

## 🚀 Features

- **Create, List, Connect, and Drop Databases**
- **Create, List, Drop Tables**
- **Insert, Select, Update, and Delete Rows**
- **Primary key enforcement and data type validation**
- **Colorful, user-friendly CLI with confirmation prompts**
- **Safe input handling and robust error checking**

---

## 🛠️ Installation & Usage

### Requirements
- Bash (version 4+ recommended)
- Linux/macOS/WSL

### Clone and Run

```bash
git clone https://github.com/Mohamedelwali/ShellScriptDBMS.git
cd ShellScriptDBMS
chmod +x ShellScriptDBMS.sh
./ShellScriptDBMS.sh
```

Or display help:

```bash
./ShellScriptDBMS.sh --help
```

---

## 📖 How It Works

- **Databases** are directories inside `./databases/`.
- **Tables** are files with metadata (`.meta`) and data.
- **All operations** are menu-driven and interactive.

---

## 🗂️ Main Menu

```
1. Create Database
2. List Databases
3. Connect To Database
4. Drop Database
5. Exit
```

### Database Menu

```
1. Create Table
2. List Tables
3. Drop Table
4. Insert into Table
5. Select From Table
6. Delete From Table
7. Update Table
8. Back to Main Menu
```

---

## 📝 Example Session

```text
Welcome to the Simple DBMS
====== DBMS Main Menu ======
1. Create Database
...
Select an option [1-5]: 1
Enter new database name: school
Database 'school' created.
...
```

---

## ⚙️ Script Structure

- **ShellScriptDBMS.sh** – Main script, contains all logic and menus

---

## 🧑‍💻 Developer Notes

- All functions are modular and documented.
- Color variables are defined at the top for easy customization.
- Input validation and confirmation prompts protect your data.
- Easily extensible for more features (see below).

---

## 🌱 Future Enhancements

- **Backup and Restore**: Archive and restore databases.
- **SQL-like Query Interface**: Support for simple SQL commands.
- **Advanced Querying**: Conditional selects, column filtering.
- **Logging**: Audit trail for all operations.
- **Transaction Support**: Commit and rollback.
- **Packaging**: Install script and user manual.

---

## 🤝 Contribution

Pull requests and suggestions are welcome!  
Please fork the repo and submit your improvements.

---

## 📄 License

MIT License.

---

## 📬 Contact

For questions or support, contact:  
Mohamed Elwaly, Hassan Amer

---

**Enjoy using Bash DBMS!**

---
