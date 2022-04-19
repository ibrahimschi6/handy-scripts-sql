-- Use select in no lock mode via hint

SELECT * FROM LockTestDemo WITH (NOLOCK)

--Update a table by using another table

UPDATE
    Sales_Import
SET
    Sales_Import.AccountNumber = RAN.AccountNumber
FROM
    Sales_Import SI
INNER JOIN
    RetrieveAccountNumber RAN
ON 
    SI.LeadID = RAN.LeadID;

