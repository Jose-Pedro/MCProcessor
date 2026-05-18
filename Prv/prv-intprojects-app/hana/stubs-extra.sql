-- Extra stubs needed by parameterized views that reference CDS-managed
-- views/entities the rest of the model couldn't deploy. Idempotent: drops
-- first, recreates as bare-minimum columns matching what the consumers select.
SET SCHEMA INTPROJ;

-- APPROVER_TYPES — referenced by BLOCKS_RESPONSIBLES (consumes code, name)
DROP TABLE APPROVER_TYPES CASCADE;
CREATE TABLE APPROVER_TYPES (
  code NVARCHAR(36) NOT NULL,
  name NVARCHAR(255),
  country NVARCHAR(3)
);

-- SUBCO_TYPES — referenced by BLOCKS_RESPONSIBLES (consumes code, name)
DROP TABLE SUBCO_TYPES CASCADE;
CREATE TABLE SUBCO_TYPES (
  code NVARCHAR(36) NOT NULL,
  name NVARCHAR(255),
  country NVARCHAR(3)
);

-- Checklist_Item — referenced by CHECKLIST_BLOCK_PHASE_REQUEST
-- The consumer view selects: ID, type_ID, block_ID
DROP TABLE Checklist_Item CASCADE;
CREATE TABLE Checklist_Item (
  ID NVARCHAR(36) NOT NULL,
  type_ID INTEGER,
  block_ID NVARCHAR(36)
);
