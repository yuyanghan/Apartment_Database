USE "KaterinaWorld";
create table Address(
   AddressID int Identity primary key not null,
   Street Varchar(200),
   City Varchar(20),
   State Varchar(20),
   ZipCode VarChar(10)
);


CREATE TABLE Building
(BuildingID INT Identity Primary Key NOT NULL,
 AddressID INT REFERENCES Address(AddressID),
 Floors INT NOT NULL,
 BuiltYear INT NOT NULL
  );
 
CREATE TABLE Unit
(UnitID INT Identity Primary Key NOT NULL,
 BuildingID INT REFERENCES Building(BuildingID),
 UnitNo VARCHAR(15) ,
 Description VARCHAR(2000) 
  );
 
CREATE TABLE UserUnit
(UserUnitID INT Identity Primary Key NOT NULL,
 UserID INT REFERENCES User(UserID),
 UnitID INT REFERENCES Unit(UnitID)
  );

 CREATE TABLE EmergencyContact
(EmergencyContactID INT Identity Primary Key NOT NULL,
 ContactFirstName VARCHAR(30),
 ContactLastName  VARCHAR(30),
 PhoneNumber  VARCHAR(20),
 Relationship VARCHAR(30)
  );
 CREATE TABLE UserEmergencyContact
(UserEmergencyContactID INT Identity Primary Key NOT NULL,
 EmergencyContactID INT REFERENCES EmergencyContact(EmergencyContactID),
 UserID INT REFERENCES User(UserID)
  );
 
 CREATE TABLE LeasingOffice
 (LeasingOfficeID INT Identity Primary Key NOT NULL,
  BuildingID INT REFERENCES Building(BuildingID),
  LeasingOfficeName VARCHAR(30),
  LeasingOfficeEmail VARCHAR(50),
  LeasingOfficePhoneNumber VARCHAR(20),
  LeasingOfficeWebsite VARCHAR(100)
  );
 
  CREATE TABLE LeasingApplication
 (LeasingApplicationID INT Identity Primary Key NOT NULL,
  UserID INT REFERENCES User(UserID),
  LeasingOfficeID INT REFERENCES LeasingOffice(LeasingOfficeID),
  UnitID INT REFERENCES Unit(UnitID),
  MoveInDate DATE,
  LeasingTerm INT,
  RentPerMonth FLOAT,
  ApplicationFee INT,
  ApplicationStatus VARCHAR(30)
  );
 USE group5;

SELECT * FROM [User];

SELECT * FROM Address;
SELECT * FROM Unit;
SELECT * FROM Building;
SELECT * FROM Billing;
SELECT * FROM LeasingAgent;
SELECT * FROM LeasingOffice;
SELECT * FROM LeasingApplication;
SELECT * FROM MaintenanceCompany;
SELECT * FROM MaintenanceServiceType;
SELECT * FROM UserUnit;
SELECT * FROM [User];
SELECT * FROM UserAddress;
SELECT * FROM UserUnit;
SELECT * FROM EmergencyContact;
SELECT * FROM UserEmergencyContact;
SELECT * FROM RentHistory;



DBCC CHECKIDENT (LeasingAgent, RESEED, 0);
GO
DBCC CHECKIDENT (EmergencyContact, RESEED, 0);
GO


 SELECT u.BuildingID,MAX(b.BillingAmount) [max billing]
 FROM Unit u JOIN Billing b ON u.UnitID =b.UnitID
 GROUP BY u.BuildingID;

   
 CREATE VIEW  MaxBillingInEachBuilding
 AS
 WITH temp AS( 
 SELECT u.BuildingID, u.UnitNo,SUM(b.BillingAmount)[Max Billing],
     RANK() OVER(PARTITION BY u.BuildingID ORDER BY SUM(b.BillingAmount) DESC) [rank]
    FROM Unit u JOIN Billing b ON u.UnitID =b.UnitID
    GROUP BY u.BuildingID, u.UnitNo)
 SELECT BuildingID, UnitNo,[Max Billing]
 FROM temp
 WHERE [rank]=1;


CREATE TRIGGER BillingAfterMovein ON Billing 
AFTER INSERT, UPDATE
AS
  IF EXISTS
      (SELECT 'TRUE'
       FROM INSERTED i
       JOIN LeasingApplication la 
       ON i.UnitID= la.UnitID 
       WHERE i.DueDate < la.MoveInDate 
        )
     BEGIN
	 ROLLBACK TRANSACTION
     RAISERROR ('The billing date should be later than the movein date.',16,1)
     END;
DROP TRIGGER BillingAfterMovein;
ALTER TABLE Billing ADD CONSTRAINT BillingAfterMovein CHECK
(dbo.CompareDueDate(UnitID)=1);

SELECT * FROM LeasingOffice ;
SELECT * FROM LeasingApplication;
SELECT * FROM Billing ;
DELETE FROM LeasingApplication;
ALTER TABLE LeasingApplication 
DROP COLUMN LeasingOffice;
DBCC CHECKIDENT (LeasingApplication, RESEED, 0);
GO
INSERT Billing Values(3,'2021-01-01',3548);

CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'group5';
-- Create certificate to protect symmetric key
CREATE CERTIFICATE aptCardnumber
WITH SUBJECT = 'apt Test Certificate',
EXPIRY_DATE = '2022-10-31';
-- Create symmetric key to encrypt data
CREATE SYMMETRIC KEY aptCardnumberKey
WITH ALGORITHM = AES_128
ENCRYPTION BY CERTIFICATE aptCardn2883umber;
ALTER TABLE Payment
     ADD EncryptedNumber Varbinary(5000);
GO
OPEN SYMMETRIC KEY aptCardnumberKey
DECRYPTION BY CERTIFICATE aptCardnumber;
UPDATE Payment 
SET EncryptedNumber =EncryptByKey(KEY_GUID('aptCardnumberKey'),
CAST(PaymentCardNumber AS VARCHAR));

CREATE VIEW UnitMember
AS
WITH temp
AS(
   SELECT ut.UnitID , CONCAT(u.FirstName,' ',u.LastName ) [Name]
    FROM UserUnit uu 
   JOIN [User] u ON uu.UserID =u.UserID
   JOIN Unit ut ON ut.UnitID =uu.UnitID
   )
 SELECT DISTINCT UnitID , STUFF((SELECT ','+ CAST([Name] AS CHAR)
                                     FROM temp t1
                                     WHERE t1.UnitID =t2.UnitID
                                     FOR XML PATH('')) , 1, 1, '')AS Names
FROM temp t2;
 
SELECT* FROM totalBillingByMonth tbbm ;
USE group5;
SELECT * FROM Billing;
SELECT * FROM LeasingApplication;

SELECT UnitID ,MoveInDate 
FROM LeasingApplication;
INSERT Billing Values(10,'2020-01-01',1700);
