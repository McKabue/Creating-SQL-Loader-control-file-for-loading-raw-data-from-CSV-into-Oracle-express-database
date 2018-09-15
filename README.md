## Creating SQL*Loader control file for loading raw data from CSV into Oracle express database

**Prerequisites**
> [Ensure Java (JDK) is installed in your Machine.](https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04)


**Tools/software used**
1. *Oracle express database*
2. *Sql Developer*

## Installation steps of Oracle Database Express Edition 11_g_ Release 2 (Linux-ubuntu)

1. Downloading *Oracle express database*.
Go to  [http://www.oracle.com/technetwork/products/express-edition/downloads/index.html](http://www.oracle.com/technetwork/products/express-edition/downloads/index.html). 
Accept the **Accept  License Agreement** and you will be prompted to login in order to proceed to download. Create account at if you don't already have one.

2. Extract the Oracle Database Express.
Once the zip  file has finished downloading, unzip the file using the command <code>unzip oracle-xe-11.2.0-1.0.x86_64.rpm.zip</code>. (*this may take some time...*)
It will extract a folder called **"Disk1"**.

3. Convert to the Linux distribution package.
The file has a <code>.rpm</code> and we must convert it to a ubuntu package (or according to the distribution you are using.In mint for exable convert to `.deb`).To achieve the conversion install <code>alien</code> using the command: `sudo apt-get install alien libaio1 unixodbc vim` , then execute the command `sudo alien --scripts -d oracle-xe-11.2.0-1.0.x86_64.rpm` to convert the downloaded file.

4. Prepare your computer for installation.
   * Create a special **chkconfig** script with the following code: `sudo gedit /sbin/chkconfig`
   Paste the following into the opened file and save it:

   <pre>
   #!/bin/bash
   # Oracle 11gR2 XE installer chkconfig hack for Ubuntu
   file=/etc/init.d/oracle-xe
   if [[ ! `tail -n1 $file | grep INIT` ]]; then
   echo >> $file
   echo '### BEGIN INIT INFO' >> $file
   echo '# Provides: OracleXE' >> $file
   echo '# Required-Start: $remote_fs $syslog' >> $file
   echo '# Required-Stop: $remote_fs $syslog' >> $file
   echo '# Default-Start: 2 3 4 5' >> $file
   echo '# Default-Stop: 0 1 6' >> $file
   echo '# Short-Description: Oracle 11g Express Edition' >> $file
   echo '### END INIT INFO' >> $file
   fi
   update-rc.d oracle-xe defaults 80 01
   </pre>

   * Provide appropriate execute privilege to the file above by executing the command: `sudo chmod 755 /sbin/chkconfig`
  
   * Set the Kernel parameters.
   Oracle 11gR2 XE requires to set the following additional kernel parameters. Open the file *60-oracle.conf* with the command `sudo gedit /etc/sysctl.d/60-oracle.conf` and paste the following:
   <pre>
   # Oracle 11g XE kernel parameters  
   fs.file-max=6815744  
   net.ipv4.ip_local_port_range=9000 65000  
   kernel.sem=250 32000 100 128 
   kernel.shmmax=536870912 
   </pre>
   Save the file.
   > Note: kernel.shmmax = max possible value , e.g. size of physical RAM ( in bytes e.g. 512MB RAM == 512*1024*1024 == 536870912 bytes )

   **Verify the change :**
   `sudo cat /etc/sysctl.d/60-oracle.conf`

   Load new kernel parameters: 
   `sudo service procps restart  `.

   **Verify: `sudo sysctl -q fs.file-max `

       fs.file-max = 6815744 

   * Increase the system swap space.
     Analyze your current swap space by following command:

       `free -m`
       
       Minimum swap space requirement of Oracle 11gR2 XE is 2 GB . In case, your is lesser , you can increase it by following steps at: [http://meandmyubuntulinux.blogspot.com/2011/09/installing-1-gb-swap-without.html](http://meandmyubuntulinux.blogspot.com/2011/09/installing-1-gb-swap-without.html).

   * Make some more required changes
     <pre>sudo ln -s /usr/bin/awk /bin/awk</pre>
     <pre>mkdir /var/lock/subsys </pre>
     <pre>sudo touch /var/lock/subsys/listener </pre>

5. At this point you are ready to install oracle database. Change directory to where you converted the database file in ubuntu(or the distribution you used) in step 3 above.Open your terminal and type:
   <pre>sudo dpkg --install oracle-xe_11.2.0-2_amd64.deb</pre>
   <pre>sudo /etc/init.d/oracle-xe configure</pre>

   Enter the following configuration information:
     <pre>
     A valid HTTP port for the Oracle Application Express (the default is 8080)  
     A valid port for the Oracle database listener (the default is 1521) 
     A password for the SYS and SYSTEM administrative user accounts
     Confirm password for SYS and SYSTEM administrative user accounts
     Whether you want the database to start automatically when the computer starts (next reboot).
     </pre>

6. Set Environmental variables before using the database.

   Open **.bashrc** by executing: `sudo gedit ~/.bashrc`. Paste the following and save.
   <pre>
   export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
   export ORACLE_SID=XE
   export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
   export ORACLE_BASE=/u01/app/oracle
   export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
   export PATH=$ORACLE_HOME/bin:$PATH
   </pre>

    Reload **.profile** to load the changes by executing: `sudo . ./.profile`

7. Start the Oracle database `sudo service oracle-xe start`

8. Create User
    * Start **sqlplus** and login as sys: `sqlplus sys as sysdba`
    * Provide the same password used during step 5 and you should see n output like this:

     <pre>
      SQL*Plus: Release 11.2.0.2.0 Production on Wed May 9 12:12:16 2012
      Copyright (c) 1982, 2011, Oracle. All rights reserved.
      Enter password:
      Connected to:
      Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

      SQL >
    </pre>
   * Enter following on the sql prompt : Replace _username1_ and _password1_ by your desired ones.
  
    <pre>
    SQL > create user username1 identified by password1;
    User created.

    SQL> grant connect,resource to username;
    Grant succeeded. 
    </pre>

    Now as you have created the user , you can login to it


## Creating a new connection with Oracle SQL Developer

1. Dowload sql developer if you don't have it installed already. Just as we did with the Oracle express database, convert it with **alien** and install it:
   <pre>sudo alien --scripts -d sqldeveloper-18.2.0.183.1748-1.noarch.rpm</pre>
   <pre>sudo dpkg --install sqldeveloper_18.2.0.183.1748-2_all.deb</pre>

2. Launch the sql developer from terminal for a Gui interface
   
   In Linux OS, type `sqldeveloper` on the terminal. If the installation was successful, you should see the Gui interface similar to the image below.
   
   Click on the green ‘+’ located top left to invoke the connection dialog box
     * Connection Name: Could be any name .E.g **retailer@localhost**

     * Username: Input the user you created.

     * Password: Input the password used in creating the user.

3. Once connection is established, click Create a database named `EMPLOYEES` and run the following SQL command to Create a table:
   <pre>
    CREATE TABLE "USERNAME1"."EMP" 
    ("EMPNO" NUMBER NOT NULL ENABLE, 
    "ENAME" VARCHAR2(20 BYTE), 
    "JOB" VARCHAR2(20 BYTE), 
    "MGR" VARCHAR2(20 BYTE), 
    "HIREDATE" VARCHAR2(20 BYTE), 
    "SAL" VARCHAR2(20 BYTE), 
    "COMM" VARCHAR2(20 BYTE), 
    "DEPTNO" VARCHAR2(20 BYTE), 
    CONSTRAINT "EMP_PK" PRIMARY KEY ("EMPNO")
    USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
    STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
    PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    TABLESPACE "SYSTEM"  ENABLE
    ) SEGMENT CREATION IMMEDIATE 
    PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
    PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    TABLESPACE "SYSTEM" ;
  </pre>
  Replace **USERNAME1** with the username you used in this connection (**The username you used when creating a user**).


## SQL* LOADER

Sql * Loader session takes as input a control file, and one or more data files.

The output is an oracle database, a log file, a bad file, and potentially a discard file.

1. Create a file named: `control.ctl` and paste the following.

    <pre>
    LOAD DATA
    APPEND
    INTO TABLE emp
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    TRAILING NULLCOLS
    (
    EMPNO,
    ENAME,
    JOB,
    MGR,
    HIREDATE DATE "dd/mm/yyyy",
    SAL,
    COMM,
    DEPTNO
    )
    </pre>

    > INSERT: It will load rows only if the target table is empty

    > APPEND: Load rows if the target table is empty or not

    > REPLACE: First delete the rows in the existing table and then load new rows

    > TRUNCATE: 1st truncates the table and then load rows

2. Create an simple **\*.CSV** and name it: `abc.csv`. Paste the following:
    <pre>
    7369,SMITH,CLERK,7902,17/12/1980,800,,20
    234,fsdf,sdfsd,45,18/12/1980,900,,1
    </pre>

3. Create a log file and name it `sqllog.log`.

4. Run the following command: `sqlldr username1/password1 data='abc.csv' control='control.ctl' log='sqllog.log'`. This assumes your username is **username1** and password is **password1**.

 If everything goes well, you could see the following in the log file:
 
<pre>
    SQL*Loader: Release 11.2.0.2.0 - Production on Fri Sep 14 02:37:22 2018

    Copyright (c) 1982, 2009, Oracle and/or its affiliates.  All rights reserved.

    Control File:   control.ctl
    Data File:      abc.csv
    Bad File:     abc.bad
    Discard File:  none specified
    
    (Allow all discards)

    Number to load: ALL
    Number to skip: 0
    Errors allowed: 50
    Bind array:     64 rows, maximum of 256000 bytes
    Continuation:    none specified
    Path used:      Conventional

    Table EMP, loaded from every logical record.
    Insert option in effect for this table: APPEND
    TRAILING NULLCOLS option in effect

    Column Name                  Position   Len  Term Encl Datatype
    ------------------------------ ---------- ----- ---- ---- ---------------------
    EMPNO                               FIRST     *   ,  O(") CHARACTER            
    ENAME                                NEXT     *   ,  O(") CHARACTER            
    JOB                                  NEXT     *   ,  O(") CHARACTER            
    MGR                                  NEXT     *   ,  O(") CHARACTER            
    HIREDATE                             NEXT     *   ,  O(") DATE dd/mm/yyyy      
    SAL                                  NEXT     *   ,  O(") CHARACTER            
    COMM                                 NEXT     *   ,  O(") CHARACTER            
    DEPTNO                               NEXT     *   ,  O(") CHARACTER            

    Record 1: Rejected - Error on table EMP.
    ORA-00001: unique constraint (USERNAME1.EMP_PK) violated


    Table EMP:
    1 Row successfully loaded.
    1 Row not loaded due to data errors.
    0 Rows not loaded because all WHEN clauses were failed.
    0 Rows not loaded because all fields were null.


    Space allocated for bind array:                 132096 bytes(64 rows)
    Read   buffer bytes: 1048576

    Total logical records skipped:          0
    Total logical records read:             2
    Total logical records rejected:         1
    Total logical records discarded:        0

    Run began on Fri Sep 14 02:37:22 2018
    Run ended on Fri Sep 14 02:37:22 2018

    Elapsed time was:     00:00:00.04
    CPU time was:         00:00:00.01
</pre>

## References
1. https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
2. https://community.oracle.com/thread/1108264
3. http://meandmyubuntulinux.blogspot.com/2012/05/installing-oracle-11g-r2-express.html
4. https://tec600.wordpress.com/2017/06/29/oracle-installation-on-ubuntu-16-04/
5. https://docs.oracle.com/cd/E11882_01/server.112/e10897/install.htm#ADMQS021
6. https://askubuntu.com/questions/665360/oracle-database-express-11-2-job-for-oracle-xe-service-failed