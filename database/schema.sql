-- MySQL dump 10.13  Distrib 8.0.38, for macos14 (arm64)
--
-- Host: dms-project-25.mysql.database.azure.com    Database: mydb
-- ------------------------------------------------------
-- Server version	8.0.42-azure

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `approve_process`
--

DROP TABLE IF EXISTS `approve_process`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `approve_process` (
  `Approval_id` int NOT NULL AUTO_INCREMENT,
  `Related_entity_type` varchar(45) NOT NULL,
  `Related_entity_id` int NOT NULL,
  `Status` varchar(45) NOT NULL,
  `Created_by` int DEFAULT NULL,
  `Created_at` datetime NOT NULL,
  `Completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`Approval_id`),
  KEY `fk_approve_process_created_by_idx` (`Created_by`),
  CONSTRAINT `fk_approve_process_created_by` FOREIGN KEY (`Created_by`) REFERENCES `associate` (`Associate_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=220 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `approve_step`
--

DROP TABLE IF EXISTS `approve_step`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `approve_step` (
  `Step_id` int NOT NULL AUTO_INCREMENT,
  `Approval_id` int NOT NULL,
  `Department_id` int DEFAULT NULL,
  `Reviewer_id` int DEFAULT NULL,
  `Decision` varchar(45) NOT NULL,
  `Review_date` datetime NOT NULL,
  `Comments` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Step_id`),
  KEY `fk_step_approval_idx` (`Approval_id`),
  KEY `fk_step_department_idx` (`Department_id`),
  KEY `fk_step_reviewer_idx` (`Reviewer_id`),
  CONSTRAINT `fk_step_approval` FOREIGN KEY (`Approval_id`) REFERENCES `approve_process` (`Approval_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step_department` FOREIGN KEY (`Department_id`) REFERENCES `department` (`Department_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_step_reviewer` FOREIGN KEY (`Reviewer_id`) REFERENCES `associate` (`Associate_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=474 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `associate`
--

DROP TABLE IF EXISTS `associate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `associate` (
  `Associate_id` int NOT NULL AUTO_INCREMENT,
  `F_name` varchar(60) NOT NULL,
  `Minit` varchar(60) DEFAULT NULL,
  `last_name` varchar(60) NOT NULL,
  `Role` varchar(100) NOT NULL,
  `Email` varchar(45) NOT NULL,
  `Phone` varchar(45) NOT NULL,
  `Department_id` int DEFAULT NULL,
  `Supervisor_id` int DEFAULT NULL,
  `Status` varchar(45) NOT NULL,
  PRIMARY KEY (`Associate_id`),
  UNIQUE KEY `Email_UNIQUE` (`Email`),
  KEY `fk_associate_supervisor_idx` (`Supervisor_id`),
  KEY `fk_associate_department` (`Department_id`),
  CONSTRAINT `fk_associate_department` FOREIGN KEY (`Department_id`) REFERENCES `department` (`Department_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_associate_supervisor` FOREIGN KEY (`Supervisor_id`) REFERENCES `associate` (`Associate_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contract`
--

DROP TABLE IF EXISTS `contract`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contract` (
  `Contract_id` int NOT NULL AUTO_INCREMENT,
  `Contract_no` varchar(60) NOT NULL,
  `Project_id` int NOT NULL,
  `Customer_id` int NOT NULL,
  `Approval_id` int DEFAULT NULL,
  `Created_by` int DEFAULT NULL,
  `Signed_date` date DEFAULT NULL,
  `Effective_date` date DEFAULT NULL,
  `Maturity_date` date DEFAULT NULL,
  `Down_payment` decimal(15,2) NOT NULL,
  `Deposit_amount` decimal(15,2) NOT NULL,
  `Interest_rate` decimal(5,2) NOT NULL,
  `Total_rent` decimal(15,2) NOT NULL,
  `Status` varchar(45) NOT NULL,
  `Created_at` datetime NOT NULL,
  `Updated_at` datetime NOT NULL,
  PRIMARY KEY (`Contract_id`),
  UNIQUE KEY `Contract_no_UNIQUE` (`Contract_no`),
  KEY `fk_contract_project_id_idx` (`Project_id`),
  KEY `fk_contract_customer_id_idx` (`Customer_id`),
  KEY `fk_contract_approval_id_idx` (`Approval_id`),
  KEY `fk_contract_created_by_idx` (`Created_by`),
  KEY `idx_contract_status` (`Status`),
  CONSTRAINT `fk_contract_approval_id` FOREIGN KEY (`Approval_id`) REFERENCES `approve_process` (`Approval_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contract_created_by` FOREIGN KEY (`Created_by`) REFERENCES `associate` (`Associate_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contract_customer_id` FOREIGN KEY (`Customer_id`) REFERENCES `party` (`Party_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contract_project_id` FOREIGN KEY (`Project_id`) REFERENCES `project` (`Project_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contract_asset`
--

DROP TABLE IF EXISTS `contract_asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contract_asset` (
  `Asset_id` int NOT NULL AUTO_INCREMENT,
  `Contract_id` int NOT NULL,
  `Asset_name` varchar(100) NOT NULL,
  `Asset_type` varchar(60) NOT NULL,
  `Acquisition_cost` decimal(15,2) NOT NULL,
  `Appraised_value` decimal(15,2) NOT NULL,
  `Book_value` decimal(15,2) NOT NULL,
  `In_service_date` date NOT NULL,
  `Location` varchar(150) NOT NULL,
  `Status` varchar(45) NOT NULL,
  `Remarks` varchar(255) DEFAULT NULL,
  `Created_at` datetime NOT NULL,
  `Updated_at` datetime NOT NULL,
  PRIMARY KEY (`Asset_id`),
  KEY `fk_asset_contract_idx` (`Contract_id`),
  CONSTRAINT `fk_asset_contract` FOREIGN KEY (`Contract_id`) REFERENCES `contract` (`Contract_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contract_funding`
--

DROP TABLE IF EXISTS `contract_funding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contract_funding` (
  `CFID` int NOT NULL AUTO_INCREMENT,
  `Contract_id` int NOT NULL,
  `Funder_id` int NOT NULL,
  `Funding_type` varchar(45) NOT NULL,
  `Agreement_no` varchar(60) NOT NULL,
  `Commitment_amount` decimal(15,2) NOT NULL,
  `Drawn_amount` decimal(15,2) NOT NULL,
  `Interest_rate` decimal(5,2) NOT NULL,
  `Effective_date` date NOT NULL,
  `Maturity_date` date NOT NULL,
  `Status` varchar(45) NOT NULL,
  `Remarks` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`CFID`),
  KEY `fk_funding_contract_idx` (`Contract_id`),
  KEY `fk_funding_funder_idx` (`Funder_id`),
  CONSTRAINT `fk_funding_contract` FOREIGN KEY (`Contract_id`) REFERENCES `contract` (`Contract_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_funding_funder` FOREIGN KEY (`Funder_id`) REFERENCES `party` (`Party_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=966 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contract_guarantee`
--

DROP TABLE IF EXISTS `contract_guarantee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contract_guarantee` (
  `Contract_guarantee_id` int NOT NULL AUTO_INCREMENT,
  `Contract_id` int NOT NULL,
  `Guarantor_id` int NOT NULL,
  `Guarantee_type` varchar(45) NOT NULL,
  `Guarantee_amount` decimal(15,2) NOT NULL,
  `Effective_date` date NOT NULL,
  `End_date` date NOT NULL,
  `Created_at` datetime NOT NULL,
  `Updated_at` datetime NOT NULL,
  PRIMARY KEY (`Contract_guarantee_id`),
  KEY `fk_guarantee_contract_idx` (`Contract_id`),
  KEY `fk_guarantee_guarantor_idx` (`Guarantor_id`),
  CONSTRAINT `fk_guarantee_contract` FOREIGN KEY (`Contract_id`) REFERENCES `contract` (`Contract_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_guarantee_guarantor` FOREIGN KEY (`Guarantor_id`) REFERENCES `party` (`Party_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credit_rating`
--

DROP TABLE IF EXISTS `credit_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credit_rating` (
  `Rating_id` int NOT NULL AUTO_INCREMENT,
  `Customer_id` int NOT NULL,
  `Rating_date` date NOT NULL,
  `Rating_score` decimal(5,2) NOT NULL,
  `Rating_level` varchar(10) NOT NULL,
  `Methodology` varchar(100) NOT NULL,
  `Evaluated_by` int DEFAULT NULL,
  `Remarks` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Rating_id`),
  KEY `fk_credit_rating_customer_idx` (`Customer_id`),
  KEY `fk_credit_rating_evaluated_by_idx` (`Evaluated_by`),
  CONSTRAINT `fk_credit_rating_customer` FOREIGN KEY (`Customer_id`) REFERENCES `party` (`Party_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_credit_rating_evaluated_by` FOREIGN KEY (`Evaluated_by`) REFERENCES `associate` (`Associate_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=156 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department` (
  `Department_id` int NOT NULL,
  `Department_name` varchar(100) NOT NULL,
  `D_type` varchar(100) NOT NULL,
  `Head_id` int DEFAULT NULL,
  `Parent_department_id` int DEFAULT NULL,
  `Department_email` varchar(100) NOT NULL,
  `Location` varchar(100) NOT NULL,
  `Created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Status` varchar(45) NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`Department_id`),
  KEY `head_department_idx` (`Head_id`),
  KEY `parent_department_idx` (`Parent_department_id`),
  CONSTRAINT `head_department` FOREIGN KEY (`Head_id`) REFERENCES `associate` (`Associate_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `parent_department` FOREIGN KEY (`Parent_department_id`) REFERENCES `department` (`Department_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document`
--

DROP TABLE IF EXISTS `document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document` (
  `Document_id` int NOT NULL AUTO_INCREMENT,
  `Related_entity` varchar(45) NOT NULL,
  `Related_id` int NOT NULL,
  `Document_name` varchar(255) NOT NULL,
  `Document_type` varchar(45) NOT NULL,
  `File_path` varchar(255) NOT NULL,
  `Uploaded_by` int DEFAULT NULL,
  `Upload_date` datetime NOT NULL,
  PRIMARY KEY (`Document_id`),
  KEY `fk_document_uploaded_by_idx` (`Uploaded_by`),
  KEY `idx_doc_lookup` (`Related_entity`,`Related_id`),
  CONSTRAINT `fk_document_uploaded_by` FOREIGN KEY (`Uploaded_by`) REFERENCES `associate` (`Associate_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=636 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `financial_data`
--

DROP TABLE IF EXISTS `financial_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_data` (
  `Financial_id` int NOT NULL AUTO_INCREMENT,
  `Customer_id` int NOT NULL,
  `Fiscal_year` varchar(4) NOT NULL,
  `Total_assets` decimal(18,2) NOT NULL,
  `Total_liabilities` decimal(18,2) DEFAULT NULL,
  `Revenue` decimal(18,2) DEFAULT NULL,
  `Net_income` decimal(18,2) DEFAULT NULL,
  `Operating_cash_flow` decimal(18,2) DEFAULT NULL,
  `Debt_ratio` decimal(5,2) DEFAULT NULL,
  `Data_source_id` int DEFAULT NULL,
  `Remarks` varchar(255) DEFAULT NULL,
  `Current_assets` decimal(18,2) DEFAULT NULL,
  `Current_liabilities` decimal(18,2) DEFAULT NULL,
  `EBITDA` decimal(18,2) DEFAULT NULL,
  `Equity` decimal(18,2) DEFAULT NULL,
  `Full_report_json` json DEFAULT NULL COMMENT 'stores full balance sheet & income statement',
  PRIMARY KEY (`Financial_id`),
  KEY `fk_financial_customer_idx` (`Customer_id`),
  KEY `fk_financial_data_source_idx` (`Data_source_id`),
  CONSTRAINT `fk_financial_customer` FOREIGN KEY (`Customer_id`) REFERENCES `party` (`Party_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_financial_data_source` FOREIGN KEY (`Data_source_id`) REFERENCES `document` (`Document_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `funding_drawdown`
--

DROP TABLE IF EXISTS `funding_drawdown`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `funding_drawdown` (
  `Drawdown_id` int NOT NULL AUTO_INCREMENT,
  `CFID` int NOT NULL,
  `Amount` decimal(15,2) NOT NULL,
  `Drawdown_date` date NOT NULL,
  `Interest_start_date` date NOT NULL,
  `Remarks` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Drawdown_id`),
  KEY `fk_drawdown_funding
_idx` (`CFID`),
  CONSTRAINT `fk_drawdown_funding
` FOREIGN KEY (`CFID`) REFERENCES `contract_funding` (`CFID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `party`
--

DROP TABLE IF EXISTS `party`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `party` (
  `Party_id` int NOT NULL AUTO_INCREMENT,
  `Party_name` varchar(150) NOT NULL,
  `Party_type` varchar(45) NOT NULL,
  `Registration_no` varchar(45) DEFAULT NULL,
  `SSN` varchar(45) DEFAULT NULL,
  `Industry` varchar(100) DEFAULT NULL,
  `Phone` varchar(45) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Address` varchar(150) NOT NULL,
  `City` varchar(45) NOT NULL,
  `State` varchar(45) NOT NULL,
  `Postal_code` varchar(20) NOT NULL,
  `Country` varchar(60) NOT NULL,
  `Status` varchar(45) NOT NULL,
  `Remarks` varchar(255) DEFAULT NULL,
  `Created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `Updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Party_id`),
  UNIQUE KEY `Registration_no_UNIQUE` (`Registration_no`),
  UNIQUE KEY `SSN_UNIQUE` (`SSN`),
  KEY `idx_party_name` (`Party_name`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_schedule`
--

DROP TABLE IF EXISTS `payment_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_schedule` (
  `Payment_id` int NOT NULL AUTO_INCREMENT,
  `Contract_id` int NOT NULL,
  `Due_date` date NOT NULL,
  `Principal_amount` decimal(15,2) NOT NULL,
  `Interest_amount` decimal(15,2) NOT NULL,
  `Fee_amount` decimal(15,2) NOT NULL,
  `Penalty_amount` decimal(15,2) NOT NULL,
  `Total_due` decimal(15,2) NOT NULL,
  `Paid_amount` decimal(15,2) NOT NULL,
  `Payment_status` varchar(45) NOT NULL,
  `Remarks` varchar(255) DEFAULT NULL,
  `Actual_payment_date` date DEFAULT NULL,
  PRIMARY KEY (`Payment_id`),
  KEY `fk_payment_contract
_idx` (`Contract_id`),
  KEY `idx_payment_due_date` (`Due_date`),
  CONSTRAINT `fk_payment_contract
` FOREIGN KEY (`Contract_id`) REFERENCES `contract` (`Contract_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4096 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `project` (
  `Project_id` int NOT NULL AUTO_INCREMENT,
  `Project_no` varchar(60) NOT NULL,
  `Customer_id` int NOT NULL,
  `Requested_amount` decimal(15,2) NOT NULL,
  `Proposed_tenor` int NOT NULL,
  `Submission_date` date NOT NULL,
  `Status` varchar(45) NOT NULL,
  `Project_manager_id` int DEFAULT NULL,
  `Project_assistant_id` int DEFAULT NULL,
  `Rating` varchar(45) DEFAULT NULL,
  `Created_at` datetime NOT NULL,
  `Updated_at` datetime NOT NULL,
  PRIMARY KEY (`Project_id`),
  KEY `Project_manager_id_idx` (`Project_manager_id`),
  KEY `customer_idx` (`Customer_id`),
  KEY `fk_project_assistant_id_idx` (`Project_assistant_id`),
  CONSTRAINT `fk_project_assistant_id` FOREIGN KEY (`Project_assistant_id`) REFERENCES `associate` (`Associate_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_project_customer_id` FOREIGN KEY (`Customer_id`) REFERENCES `party` (`Party_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_project_manager_id` FOREIGN KEY (`Project_manager_id`) REFERENCES `associate` (`Associate_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_contract_summary`
--

DROP TABLE IF EXISTS `v_contract_summary`;
/*!50001 DROP VIEW IF EXISTS `v_contract_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_contract_summary` AS SELECT 
 1 AS `Contract_no`,
 1 AS `Party_name`,
 1 AS `Total_rent`,
 1 AS `Status`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_contract_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_contract_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`fei`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_contract_summary` AS select `c`.`Contract_no` AS `Contract_no`,`p`.`Party_name` AS `Party_name`,`c`.`Total_rent` AS `Total_rent`,`c`.`Status` AS `Status` from (`contract` `c` join `party` `p` on((`c`.`Customer_id` = `p`.`Party_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-18 21:19:37
