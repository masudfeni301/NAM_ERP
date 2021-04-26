grant execute on utl_file to NAM_ERP_SOL;

CREATE OR REPLACE DIRECTORY IMG_DIR AS 'C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\i\Store_Images';

GRANT EXECUTE, READ, WRITE ON DIRECTORY IMG_DIR TO NAM_ERP_SOL;

CREATE OR REPLACE PROCEDURE blob_to_file (p_blob      IN OUT NOCOPY BLOB,
                                          p_dir       IN  VARCHAR2,
                                          p_filename  IN  VARCHAR2)
AS
  l_file      UTL_FILE.FILE_TYPE;
  l_buffer    RAW(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_blob_len  INTEGER;
BEGIN
  l_blob_len := DBMS_LOB.getlength(p_blob);
  
  -- Open the destination file.
  l_file := UTL_FILE.fopen(p_dir, p_filename,'WB', 32767);

  -- Read chunks of the BLOB and write them to the file until complete.
  WHILE l_pos <= l_blob_len LOOP
    DBMS_LOB.read(p_blob, l_amount, l_pos, l_buffer);
    UTL_FILE.put_raw(l_file, l_buffer, TRUE);
    l_pos := l_pos + l_amount;
  END LOOP;
  
  -- Close the file.
  UTL_FILE.fclose(l_file);
  
EXCEPTION
  WHEN OTHERS THEN
   -- Close the file if something goes wrong.
    IF UTL_FILE.is_open(l_file) THEN
      UTL_FILE.fclose(l_file);
    END IF;
    RAISE;
/* WHEN UTL_FILE.invalid_operation THEN dbms_output.PUT_LINE('cannot open file invalid name');
WHEN UTL_FILE.read_error THEN dbms_output.PUT_LINE('cannot be read');
WHEN no_data_found THEN dbms_output.PUT_LINE('end of file');

UTL_FILE.fclose(l_file);
 RAISE;*/
END blob_to_file;
/

------------------------------table created--------------------
create table EMPLOYEE_INFORMATION_IMAGE (
employee_id number generated always as identity(start with 1) primary key,
employee_name varchar2(100),
designation varchar2(100),
joining_date date,
fathers_name varchar2(200)
);
------------------------------------------------------------


 '<img src="http://localhost:8080/i/image_store/'||EMPLOYEE_ID||'.jpg" alt="&EMPLOYEE_NAME." height="80" width="70"/>' Image
 
  l_blob  BLOB;
VID NUMBER;
BEGIN

 select  BLOB_CONTENT INTO   l_blob  FROM apex_application_temp_files
         where NAME= :P72_IMAGE;
 
INSERT INTO   EMPLOYEE_INFORMATION_IMAGE(EMPLOYEE_NAME,DESIGNATION,JOINING_DATE,FATHERS_NAME)
VALUES(:P72_EMPLOYEE_NAME,:P72_DESIGNATION,:P72_JOINING_DATE,:P72_FATHER_NAME) 
returning EMPLOYEE_ID into VID;

 blob_to_file(p_blob     => l_blob,
               p_dir      => 'IMG_DIR',
               p_filename => VID||'.jpg');



  
END;
