ALREADY_INSTALLED=$(odbcinst -v -q -d -n "ODBC Driver 18 for SQL Server"|grep -c "Driver")
ALREADY_INSTALLED_VERSION=$(odbcinst -v -q -d -n "ODBC Driver 18 for SQL Server"|grep -c "17.4.so.2.1")

if [ $ALREADY_INSTALLED = "1" ]; then
    if [ $ALREADY_INSTALLED_VERSION = "0" ]; then
	odbcinst -u -n "ODBC Driver 18 for SQL Server"
	odbcinst -i -d -f /opt/microsoft/msodbcsql/etc/odbcinst.ini
    fi
else 
    odbcinst -i -d -f /opt/microsoft/msodbcsql/etc/odbcinst.ini
fi
