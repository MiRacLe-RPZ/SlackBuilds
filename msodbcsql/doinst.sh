odbcinst -v -q -d -n "ODBC Driver 17 for SQL Server" >/dev/null || odbcinst -i -d -f opt/microsoft/msodbcsql/etc/odbcinst.ini
