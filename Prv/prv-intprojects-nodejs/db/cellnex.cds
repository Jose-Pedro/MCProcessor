using {
    managed,
    User,
    cuid
} from '@sap/cds/common';

@cds.persistence.exists
entity REQUEST_HEAD {
    key REQUEST_ID                                : String(36)    @title: '{i18n>ID}'                       @readonly;
        ASSIGNATION_DATE                          : Timestamp     @title: '{i18n>assignationDate}';
        CANCELLATION_COMMENTS                     : String(2000)  @title: '{i18n>comments}';
        CANCELLATION_PHASE_ID                     : String(36)    @title: 'CANCELLATION_PHASE_ID'           @readonly;
        CANCELLATION_REASON                       : String(200)   @title: '{i18n>cancellationReason}';
        COMUNIDAD_ID                              : String(100)   @title: '{i18n>company}'                  @readonly;
        COUNTRY_ID                                : String(3)     @title: '{i18n>country}'                  @readonly;
        CREATEDAT                                 : Timestamp     @title: '{i18n>createdAt}'                @readonly;
        CREATEDBY                                 : String(100)   @title: 'CREATEDBY'                       @readonly;
        DELETED_AT                                : Timestamp     @title: '{i18n>deletedAt}'                @readonly;
        DELETED_BY                                : String(100)   @title: '{i18n>deletedBy}'                @readonly;
        ENDED_AT                                  : Timestamp     @title: '{i18n>closedAt}'                 @readonly;
        MODIFIEDAT                                : Timestamp     @title: '{i18n>modifiedAt}'               @readonly;
        MODIFIEDBY                                : String(100)   @title: '{i18n>modifiedBy}'               @readonly;
        PROCESS_ID                                : String(20)    @title: '{i18n>processFlowId}'            @readonly;
        REQUEST_CODE                              : String(100)   @title: '{i18n>code}'                     @readonly;
        REQUEST_DESCRIPTION                       : String(200)   @title: '{i18n>description}';
        REQUEST_OWNER_ID                          : String(36)    @title: '{i18n>colocationManager}';
        // REQUEST_OWNER_NAME: String(100)  @title: 'REQUEST_OWNER_NAME' ;
        REQUEST_STATUS                            : Integer       @title: '{i18n>status}'                   @readonly;
        REQUEST_TYPE                              : Integer       @title: '{i18n>requestType}';
        ROLE_ID                                   : String(36)    @title: 'ROLE_ID'                         @readonly;
        SITE_ID                                   : String(36)    @title: '{i18n>siteId}';
        STARTED_AT                                : Timestamp     @title: '{i18n>openAt}'                   @readonly;
        WORKFLOW_ID : String(36)   @title: '{i18n>creationConfig}';
        WORKFLOW_NAME: String(100)  @title: 'WORKFLOW_NAME' ;
        // WORKFLOW_OWNER_ID: String(36)  @title: 'WORKFLOW_OWNER_ID' ;
        // WORKFLOW_ROLE_OWNER: String(100)  @title: 'WORKFLOW_ROLE_OWNER' ;
        // WORKFLOW_ROLE_OWNER_ID: String(36)  @title: 'WORKFLOW_ROLE_OWNER_ID' ;
        ON_HOLD_COMMENTS                          : String(2000)  @title: '{i18n>onHoldComments}';
        ON_HOLD_PHASE_ID                          : String(36)    @title: 'ON_HOLD_PHASE_ID'                @readonly;
        ON_HOLD_REASON                            : String(200)   @title: '{i18n>onHoldReason}';
        // MODIFIEDBULK_AT                           : Timestamp     @title: 'MODIFIEDBULK_AT'                 @readonly;
        // MODIFIEDBULK_BY                           : String(100)   @title: 'MODIFIEDBULK_BY'                 @readonly;
        // CREATEDBULK_AT                            : Timestamp     @title: 'CREATEDBULK_AT'                  @readonly;
        // CREATEDBULK_BY                            : String(100)   @title: 'CREATEDBULK_BY'                  @readonly;
        // DELETEDBULK_AT                            : Timestamp     @title: 'DELETEDBULK_AT'                  @readonly;
        // DELETEDBULK_BY                            : String(100)   @title: 'DELETEDBULK_BY'                  @readonly;
        virtual documentUpdated                   : Boolean;
        virtual inventoryUpdated                  : Boolean;
        virtual servicesUpdated                   : Boolean;
        virtual CLASSIFICATIONVT                  : Integer       @title: '{i18n>classification}'           @Core.Computed: false;
        virtual requestedDate                     : Timestamp     @title: '{i18n>requestedDate}'            @Core.Computed: false;    
        virtual projectObjective                  : Integer       @title: '{i18n>projectObjective}'         @Core.Computed: false;    
        virtual preferredProvider                 : String(50)    @title: '{i18n>prefererredProvider}'      @Core.Computed: false;
        virtual requestTypeFC                     : UInt8 default 3;
        virtual assignationDateFC                 : UInt8 default 3;
        virtual managerFC                         : UInt8 default 3;
        virtual classificationFC                  : UInt8 default 3;
        // virtual requestedDateFC                   : UInt8 default 3;
        virtual descriptionFC                     : UInt8 default 3;
        virtual companyFC                         : UInt8 default 3;
        virtual createdAtFC                       : UInt8 default 1;
        virtual siteIdFC                          : UInt8 default 3;
        virtual DOCUMENT_ID                       : String(50)    @title: '{i18n>documentId}'               @Core.Computed: false;
}

@cds.persistence.exists
entity REQUEST_CHAR_PRO {
    key REQUEST_ID                              : String(36)   @title: '{i18n>ID}'                  @readonly;
        CREATEDAT                               : Timestamp    @title: 'CREATEDAT'                  @readonly;
        CREATEDBY                               : String(100)  @title: 'CREATEDBY'                  @readonly;
        DELETED                                 : Boolean      @title: '{i18n>deleted}'             @readonly;
        DELETED_AT                              : Timestamp    @title: '{i18n>deletedAt}'           @readonly;
        DELETED_BY                              : String(100)  @title: '{i18n>deletedBy}'           @readonly;
        MODIFIEDAT                              : Timestamp    @title: 'MODIFIEDAT'                 @readonly;
        MODIFIEDBY                              : String(100)  @title: 'MODIFIEDBY'                 @readonly;
        // OK_SM_DATE: Timestamp  @title: 'OK_SM_DATE' ;
        // OK_SM_EXPECTED_DATE: Timestamp  @title: 'OK_SM_EXPECTED_DATE' ;
        PREFERRED_PROVIDER                      : String(50)   @title: '{i18n>prefererredProvider}';
        PREFERRED_PROVIDER_NAME            : String(50)            @title: 'PREFERRED_PROVIDER_NAME';
        REQUESTED_DATE                          : Timestamp    @title: '{i18n>requestedDate}';
        REQUESTER                               : String(100)  @title: '{i18n>requester}';
        FORESCAST_DONE                          : Boolean      @title: 'FORESCAST_DONE'             @readonly;
        PMO_MANAGER                             : String(100)  @title: '{i18n>PMOManager}';
        CLASIFICATION                           : Integer      @title: '{i18n>classification}';
        SF_OPPORTUNITY_ID                       : String(36)   @title: '{i18n>oportunityId}';
        MOA_OPERATION                           : Integer      @title: '{i18n>moaOperation}';
        // QUOTE_ID: String(36)                            @title: '{i18n>quoteId}';
        PROJECT_OBJECTIVE                       : Integer @title: '{i18n>projectObjective}';
        virtual requesterName                   : String(200);
        virtual PMOManagerName                  : String(200);
        virtual requestedDateFC                 : UInt8 default 3;
        virtual requesterFC                     : UInt8 default 3;
        virtual PMOManagerFC                    : UInt8 default 3;
        virtual priorityFC                      : UInt8 default 3;
        virtual preferredProviderFC             : UInt8 default 3;
        virtual classificationFC                : UInt8 default 3;
        virtual salesforceRequestIdFC           : UInt8 default 3;
        // virtual quoteIdFC                       : UInt8 default 3;
        virtual projectObjectiveFC              : UInt8 default 3;
        virtual moaOperationFC                  : UInt8 default 3;
}

@cds.persistence.exists
entity PHASE_HEAD {
    key PHASE_ID               : String(36)   @title: 'PHASE_ID'            @readonly;
        CREATEDAT              : Timestamp    @title: 'CREATEDAT'           @readonly;
        CREATEDBY              : String(100)  @title: 'CREATEDBY'           @readonly;
        DELETED                : Boolean      @title: 'DELETED'             @readonly;
        DELETED_AT             : Timestamp    @title: 'DELETED_AT'          @readonly;
        DELETED_BY             : String(100)  @title: 'DELETED_BY'          @readonly;
        ENDED_AT               : Timestamp    @title: 'ENDED_AT'            @readonly;
        MASTER_PHASE_ID        : String(36)   @title: 'MASTER_PHASE_ID'     @readonly;
        MODIFIEDAT             : Timestamp    @title: 'MODIFIEDAT'          @readonly;
        MODIFIEDBY             : String(100)  @title: 'MODIFIEDBY'          @readonly;
        PHASE_OWNER            : String(100)  @title: 'PHASE_OWNER';
        PHASE_STATUS           : Integer      @title: 'PHASE_STATUS'        @readonly;
        REQUEST_ID             : String(36)   @title: 'REQUEST_ID'          @readonly;
        STARTED_AT             : Timestamp    @title: 'STARTED_AT';
        virtual CLOSE_BLOCK    : Boolean;
        virtual HAS_CANDIDATES : Boolean;
        virtual ACTIVATED      : Boolean;
}

@cds.persistence.exists
entity BLOCK_HEAD {
    key BLOCK_ID                            : String(36)                @title: 'BLOCK_ID'              @readonly;
        ACTIVATED                           : Boolean default false     @title: 'ACTIVATED';
        BLOCK_STATUS                        : Integer                   @title: '{i18n>status}'         @readonly;
        COMMENTS                            : String(2500)              @title: '{i18n>comments}';
        CREATEDAT                           : Timestamp                 @title: 'CREATEDAT'             @readonly;
        CREATEDBY                           : String(100)               @title: 'CREATEDBY'             @readonly;
        // DELETED: Boolean                        @title: 'DELETED' ;
        DELETED_AT                          : Timestamp                 @title: 'DELETED_AT'            @readonly;
        DELETED_BY                          : String(100)               @title: 'DELETED_BY'            @readonly;
        ENDED_AT                            : Timestamp                 @title: '{i18n>closedAt}'       @readonly;
        MASTER_BLOCK_ID                     : String(36)                @title: '{i18n>processFlowId}'  @readonly;
        MODIFIEDAT                          : Timestamp                 @title: 'MODIFIEDAT'            @readonly;
        MODIFIEDBY                          : String(100)               @title: 'MODIFIEDBY'            @readonly;
        PHASE_ID                            : String(36)                @title: 'PHASE_ID'              @readonly;
        ROLE_ID                             : String(36)                @title: 'ROLE_ID'               @readonly;
        STARTED_AT                          : Timestamp                 @title: '{i18n>openAt}';
        MANDATORY                           : String(1)                 @title: 'MANDATORY'             @readonly;
        OWNER_ID                            : String(36)                @title: '{i18n>owner}';
        virtual openAtFC                    : UInt8                     @title : '{i18n>openAt}';    
        virtual closedAtFC                  : UInt8                     @title : '{i18n>closedAt}';    
        virtual cancellationReason          : String(2000)              @Core.Computed: false @UI.MultiLineText;
        virtual DOCUMENT_ID                 : String(50)                @title: '{i18n>documentType}'     @Core.Computed: false;
        virtual REGISTER_ID                 : String(36)                @title: '{i18n>documentId}'     @Core.Computed: false;
        virtual dpbVisibleVF                : Boolean default false     @title: '{i18n>dpbVisible}';
        virtual worksVisibleVF              : Boolean default false;
        virtual checklistVisibleVF          : Boolean default false;
        virtual commentsFC                  : UInt8 default 3;
        virtual commentsPLUFC               : UInt8 default 3;
        virtual contractRestrictionsFC      : UInt8 default 3;
}

@cds.persistence.exists
entity BLOCKS_PROVISIONING {
    key BLOCK_ID                                  : String(36)            @title: '{i18n>ID}'             @readonly;
        //     ACCEPTANCE_REJECTION_DATE: Timestamp  @title: 'ACCEPTANCE_REJECTION_DATE' ;
        ACCEPTED_REJECTED                         : String(5)             @title: '{i18n>accepted}';
        ACCEPTED_REJECTED_DATE                    : Timestamp             @title: '{i18n>acceptedDate}';
        // ACCOUNT_MANAGER_NAME                      : String(100)           @title: '{i18n>accountManagerName}';
        // ACCOUNT_MANAGER_EMAIL                     : String(80)            @title: '{i18n>accountManagerNameMail}';
        // ACCOUNT_MANAGER_PHONE                     : String(20)            @title: '{i18n>accountManagerPhone}';
        //     ACTIVATED_DE_ACTIVATED: String(5)  @title: 'ACTIVATED_DE_ACTIVATED' ;
        ACTIVATION_REASON                         : String(100)           @title: '{i18n>activationReason}';
        // ADAPTIONS_CHECK_TYPE                      : String(30)            @title: '{i18n>adaptionsCheckType}';
        //     ADAPTIONS_DESCRIPTION: String(2000)  @title: 'ADAPTIONS_DESCRIPTION' ;
        //     ADAPTIONS_NEEDED: String(5)  @title: 'ADAPTIONS_NEEDED' ;
        ADAPTIONS_TYPE                            : String(5)  @title: '{i18n>adaptionsType}' ;
        //     ADMINISTRATIVE_AUTHORIZATION_NEEDED: String(5)  @title: 'ADMINISTRATIVE_AUTHORIZATION_NEEDED' ;
        //     AGREED_SOLUTION: String(2000)  @title: 'AGREED_SOLUTION' ;
        //     ANNUAL_SUB_LEASE_COST: Double  @title: 'ANNUAL_SUB_LEASE_COST' ;
        // ANNUAL_SUB_LEASE_COST_PERCENTAGE          : Double                @title: '{i18n>sharerPayaway}';
        //     ANSWER_FROM_THE_AGENCY_DATE: Timestamp  @title: 'ANSWER_FROM_THE_AGENCY_DATE' ;
        // ARE_ADAPTATIONS_OK                        : String(5)             @title: '{i18n>adaptionsOk}';
        // ARE_THERE_ANY_EXTRAORDINARY_COSTS         : String(5)             @title: '{i18n>areExtraordinaryCost}';
        //     ASSIGNED_AGENCY: String(100)  @title: 'ASSIGNED_AGENCY' ;
        //     ASSIGNED_AGENCY_CONTACT: String(100)  @title: 'ASSIGNED_AGENCY_CONTACT' ;
        //     ASSIGNED_AGENCY_CONTACT_EMAIL: String(80)  @title: 'ASSIGNED_AGENCY_CONTACT_EMAIL' ;
        ASSIGNED_RESPONSIBLE                      : String(100)           @title: '{i18n>assignedResponsible}';
        AUTOMATIC_MANUAL_RESPONSE                 : String(100)           @title: '{i18n>automaticManualResponse}';
        //     AVAILABLE_SITE_FOUND_ID: String(36)  @title: 'AVAILABLE_SITE_FOUND_ID' ;
        //     BLOCK_ACTIVATION_DATE: Timestamp  @title: 'BLOCK_ACTIVATION_DATE' ;
        // BLOCK_STATUS                              : Integer               @title: '{i18n>status}'         @readonly;
        BTTN_DOC_UPDATED                          : String(5)  @title: 'BTTN_DOC_UPDATED' ;
        BTTN_INV_UPDATED                          : String(5)  @title: 'BTTN_INV_UPDATED' ;
        BTTN_SERV_UPDATED                         : String(5)  @title: 'BTTN_SERV_UPDATED' ;
        //     BTTN_SERV_NEEDED: String(5)  @title: 'BTTN_SERV_NEEDED' ;
        //     CANCELLATION_TYPE: Integer  @title: 'CANCELLATION_TYPE' ;
        //     CABIN_INSTALLED: Timestamp  @title: 'CABIN_INSTALLED' ;
        //     CARRY_OUT_BY: String(100)  @title: 'CARRY_OUT_BY' ;
        // CELLNEX_CONTACT_WITH_THE_AGENCY           : String(100)           @title: '{i18n>agencyContact}';
        // CELLNEX_CONTACT_WITH_THE_AGENCY_EMAIL     : String(80)            @title: '{i18n>agencyContactMail}';
        //     CELLNEX_DAYS: Integer  @title: 'CELLNEX_DAYS' ;
        //     CELLNEX_RESPONSIBLE_EMAIL: String(80)  @title: 'CELLNEX_RESPONSIBLE_EMAIL' ;
        //     CELLNEX_RESPONSIBLE_NAME: String(100)  @title: 'CELLNEX_RESPONSIBLE_NAME' ;
        //     CELLNEX_RESPONSIBLE_PHONE: String(20)  @title: 'CELLNEX_RESPONSIBLE_PHONE' ;
        //     CELLNEX_ROLE: String(100)  @title: 'CELLNEX_ROLE' ;
        //     CELLNEX_ZONE: String(100)  @title: 'CELLNEX_ZONE' ;
        //     CHECK_DATE: Timestamp  @title: 'CHECK_DATE' ;
        //     CHECK_PREVIOUS_FEASIBILITY: String(5)  @title: 'CHECK_PREVIOUS_FEASIBILITY' ;
        //     CLASSIFICATION_FIELD: String(100)  @title: 'CLASSIFICATION_FIELD' ;
        // CLIENT_TECHNICAL_CONTACT_MAIL             : String(80)            @title: '{i18n>customerTechnicalMail}';
        // CLIENT_TECHNICAL_CONTACT_PHONE            : String(20)            @title: '{i18n>customerTechnicalPhone}';
        //     COMMENTS: String(2000)  @title: 'COMMENTS' ;
        //     COMMERCIAL_PROGRAM: String(100)  @title: 'COMMERCIAL_PROGRAM' ;
        //     COMMERCIAL_TECHNICAL_CONTACT_EMAIL: String(80)  @title: 'COMMERCIAL_TECHNICAL_CONTACT_EMAIL' ;
        //     COMMERCIAL_TECHNICAL_CONTACT_NAME: String(100)  @title: 'COMMERCIAL_TECHNICAL_CONTACT_NAME' ;
        //     COMMERCIAL_TECHNICAL_CONTACT_PHONE: String(20)  @title: 'COMMERCIAL_TECHNICAL_CONTACT_PHONE' ;
        //     COMMUNICATE_NEW_RENTAL_CUSTOMER_DATE: Timestamp  @title: 'COMMUNICATE_NEW_RENTAL_CUSTOMER_DATE' ;
        COMPLETED_BY                              : String(100)           @title: '{i18n>completedBy}';
        COMPLETED_DATE                            : Timestamp             @title: '{i18n>completedDate}'  @readonly;
        COMPLEXITY                                : String(100)           @title: '{i18n>complexity}' ;
        CONTRACT_RESTRICTIONS                     : String(100)           @title: '{i18n>contractRestrictions}' ;
        //     COST: Double  @title: 'COST' ;
        CREATEDAT                                 : Timestamp             @title: 'CREATEDAT'             @readonly;
        CREATEDBY                                 : String(100)           @title: 'CREATEDBY'             @readonly;
        CURRENCY                                  :  String(3)             @title: '{i18n>currency}' default 'EUR';
        // CUSTOMER_CONFIRMS_TX_COMPLETE             : Timestamp             @title: '{i18n>confirmTxDate}';
        //     CUSTOMER_DAYS: Integer  @title: 'CUSTOMER_DAYS' ;
        //     CUSTOMER_REQUEST_CODE: String(36)  @title: 'CUSTOMER_REQUEST_CODE' ;
        //     CUSTOMER_SITE_RESPONSIBLE_EMAIL: String(80)  @title: 'CUSTOMER_SITE_RESPONSIBLE_EMAIL' ;
        //     CUSTOMER_SITE_RESPONSIBLE_NAME: String(100)  @title: 'CUSTOMER_SITE_RESPONSIBLE_NAME' ;
        //     CUSTOMER_SUB_CONTRACTOR: String(100)  @title: 'CUSTOMER_SUB_CONTRACTOR' ;
        //     CUSTOMERS_TECHNICAL_CONTACT_EMAIL: String(80)  @title: 'CUSTOMERS_TECHNICAL_CONTACT_EMAIL' ;
        //     CUSTOMERS_TECHNICAL_CONTACT_NAME: String(100)  @title: 'CUSTOMERS_TECHNICAL_CONTACT_NAME' ;
        //     CUSTOMERS_TECHNICAL_CONTACT_PHONE: String(20)  @title: 'CUSTOMERS_TECHNICAL_CONTACT_PHONE' ;
        DELETED                                   : Boolean               @title: 'DELETED'               @readonly;
        DELETED_AT                                : Timestamp             @title: 'DELETED_AT'            @readonly;
        DELETED_BY                                : String(100)           @title: 'DELETED_BY'            @readonly;
        DESCRIPTION                               : String(200)           @title: '{i18n>description2}' ;
        //     DURATION: Integer  @title: 'DURATION' ;
        // ELAPSED_TIME                              : Double                @title: '{i18n>elapsedTime}';
        //     EMAIL: String(80)  @title: 'EMAIL' ;
        END_DATE                                  : Timestamp             @title: '{i18n>endDate}';
        ENDED_AT                                  : Timestamp             @title: '{i18n<closedAt}'       @readonly;
        //     EQUIPMENT_INSTALLATION: String(100)  @title: 'EQUIPMENT_INSTALLATION' ;
        //     EQUIPMENT_INSTALLATION_CHECK_TYPE: String(100)  @title: 'EQUIPMENT_INSTALLATION_CHECK_TYPE' ;
        //     EQUIPMENT_INSTALLATION_RESPONSIBLE: String(100)  @title: 'EQUIPMENT_INSTALLATION_RESPONSIBLE' ;
        // EXCEEDING_SLA                             : String(100)           @title: '{i18n>exceedSLA}';
        EXPECTED_DATE                             : Timestamp             @title: '{i18n>expectedDate}';
        EXPECTED_END_DATE                         : Timestamp             @title: '{i18n>expectedEndDate}';
        EXPECTED_START_DATE                       : Timestamp             @title: '{i18n>expectedStartDate}';
        // EXTRAORDINARY_COSTS                       : Double                @title: '{i18n>extraCostAmount}';
        //     EXTRAORDINARY_INCREASE_OF_RENT: Double  @title: 'EXTRAORDINARY_INCREASE_OF_RENT' ;
        //     FEASIBILITY_RESULT: String(5)  @title: 'FEASIBILITY_RESULT' ;
        // FEASIBILITY_RISK: String(5)                                     @title: '{feasibilityRisk}' ;
        //     FEASIBILITY_TYPE: String(5)  @title: 'FEASIBILITY_TYPE' ;
        //     FREE_ISSUE_EQUIPMENT_RECEIVED: Timestamp  @title: 'FREE_ISSUE_EQUIPMENT_RECEIVED' ;
        //     FREE_ISSUE_EQUIPMENT_REQUESTED: Timestamp  @title: 'FREE_ISSUE_EQUIPMENT_REQUESTED' ;
        //     IMMEDIATE_MAD: String(100)  @title: 'IMMEDIATE_MAD' ;
        //     INFRASTRUCTURE_ORIGIN: String(100)  @title: 'INFRASTRUCTURE_ORIGIN' ;
        //     IS_IT_FEASIBLE: String(5)  @title: 'IS_IT_FEASIBLE' ;
        //     IS_THE_EQUIPMENT_WORKING_CORRECTLY: String(100)  @title: 'IS_THE_EQUIPMENT_WORKING_CORRECTLY' ;
        KICK_OFF_VISIT_NEEDED                     : String(5)             @title: '{i18n>visitNeeded}';
        //     LANDLORD_NAME: String(250)  @title: 'LANDLORD_NAME' ;
        //     LICENSE_RENTAL_RATE: Double  @title: 'LICENSE_RENTAL_RATE' ;
        //     LIMIT_AMOUNT_FOR: String(100)  @title: 'LIMIT_AMOUNT_FOR' ;
        // METER_BOX_INSTALLED                       : Timestamp             @title: '{i18n>meterBoxDate}';
        //     MIGRATION_REQUEST_ID: String(100)  @title: 'MIGRATION_REQUEST_ID' ;
        //     MODIFICATION_TYPE: String(100)  @title: 'MODIFICATION_TYPE' ;
        MODIFIEDAT                                : Timestamp             @title: 'MODIFIEDAT'            @readonly;
        MODIFIEDBY                                : String(100)           @title: 'MODIFIEDBY'            @readonly;
        //     MUTU_END_DATE: Timestamp  @title: 'MUTU_END_DATE' ;
        //     MUTU_START_DATE: Timestamp  @title: 'MUTU_START_DATE' ;
        NEED_KICK_OFF_VISIT                       : String(100)           @title: '{i18n>kickOffVisitNeeded}';
        //     NIS_LEADER: String(100)  @title: 'NIS_LEADER' ;
        //OPPORTUNITY_ID: String(36)  @title: '{i18n>opportunityId}' ;
        //     OPTICAL_FIBER_OPERATOR_ID: String(36)  @title: 'OPTICAL_FIBER_OPERATOR_ID' ;
        //     PARC: String(100)  @title: 'PARC' ;
        PERMITS_NEEDED                            : String(5)             @title: '{i18n>permitsNeeded}';
        //     PHASE_ID: String(36)  @title: 'PHASE_ID' ;
        PLANNED_DATE                              : Timestamp             @title: '{i18n>plannedDate}';
        PLANNED_KICK_OFF_DATE                     : Timestamp             @title: '{i18n>plannedKickoffDate}';
        //     PLANNING_PERMISSION_END_DATE: Timestamp  @title: 'PLANNING_PERMISSION_END_DATE' ;
        PLANNING_RATING                           : String(100)           @title: '{i18n>planningRating}';
        //     PMO_MANAGER: String(100)  @title: 'PMO_MANAGER' ;
        // POWER_CONNECTED_CAB_IN                    : Timestamp             @title: '{i18n>powerConnectedDate}';
        //     PRE_FEASIBILITY_CHECK: String(5)  @title: 'PRE_FEASIBILITY_CHECK' ;
        //     PREFERRED_SUBCONTRACTOR: String(100)  @title: 'PREFERRED_SUBCONTRACTOR' ;
        // PRETIPIN                                  : String(100)           @title: '{i18n>preTipin}' ;
        // PRIORITY_ASSESSMENT_COMPLETE              : Timestamp             @title: '{i18n>priorityAssesmentComplete}';
        //     PROJECT: String(100)  @title: 'PROJECT' ;
        // PROVIDER_CONTACT_EMAIL                    : String(80)            @title: '{i18n>providerMail}';
        // PROVIDER_CONTACT_PHONE                    : String(20)            @title: '{i18n>providerPhone}';
        PROVIDER_NAME                             : String(100)           @title: '{i18n>externalResponsible}';
        RESPONSIBLE_PERSON                        : String(100)           @title: '{i18n>internalResponsible}';
        // PROVIDER_USER_NAME                        : String(100)           @title: '{i18n>providerUserName}' ;
        //     RANSHARING: String(100)  @title: 'RANSHARING' ;
        REAL_DATE_SURVEY                          : Timestamp             @title: '{i18n>siteSurveyDate}';
        REAL_END_DATE                             : Timestamp             @title: '{i18n>realEndDate}';
        REAL_START_DATE                           : Timestamp             @title: '{i18n>realStartDate}';
        REJECTION_CAUSE                           : String(2000)          @title: '{i18n>rejectionReason}';
        RENEGO_NEEDED                             : String(5)             @title: '{i18n>renegoNeeded}';
        //     RENEGOTIATION_REQUEST_FILLED: Timestamp  @title: 'RENEGOTIATION_REQUEST_FILLED' ;
        //     RENT: Double  @title: 'RENT' ;
        // RENTAL_RATE                               : Double                @title: '{i18n>rentalRate}';
        //     RENTAL_RENEGOTATION_NEEDED: String(5)  @title: 'RENTAL_RENEGOTATION_NEEDED' ;
        //     REQUEST_DATE: Timestamp  @title: 'REQUEST_DATE' ;
        //     RESTRICTION_CONSIGNATION: String(200)  @title: 'RESTRICTION_CONSIGNATION' ;
        RESULT_MAD                                : Integer               @title: '{i18n>madResult}';
        //     SALES_FORCE_REQUEST_ID: String(100)  @title: 'SALES_FORCE_REQUEST_ID' ;
        // SCAT_CATEGORY                             : String(100)           @title: '{i18n>scatCategory}';
        SEND_OFFER_DATE                           : Timestamp             @title: '{i18n>sendOfferDate}';
        //     SITE_READY_DATE: Timestamp  @title: 'SITE_READY_DATE' ;
        //     SITE_RESTRICTIONS_DESC: String(200)  @title: 'SITE_RESTRICTIONS_DESC' ;
        SITE_SURVEY_WILL_BE_NEEDED                : String(5)             @title: '{i18n>siteSurveyWillBeNeeded}' ;
        START_DATE                                : Timestamp             @title: '{i18n>startedAt}';
        STATUS                                    : Integer               @title: '{i18n>status}' ;
        //     STRENGTH_CALCULATION_DOCUMENTATION: String(100)  @title: 'STRENGTH_CALCULATION_DOCUMENTATION' ;
        // STRENGTH_CALCULATION_COST_REQUEST_DATE    : Timestamp             @title: '{i18n>strengthCalcCostRequestDate}';
        // STRENGTH_CALCULATION_COST_APPROVAL_DATE   : Timestamp             @title: '{i18n>strengthCalcCostApprovalDate}';
        // STRENGTH_CALCULATION_REQUIRED             : Boolean default false @title: '{i18n>strenghtCalcRequired}';
        // STRENGTHENING_PROGRAMME_AGREED            : Timestamp             @title: '{i18n>strengtheninigAgreed}' ;
        // STRENGTHENING_REQUIRED                    : String(5)             @title: '{i18n>strengtheningRequired}';
        //     SUB_COOWNER_ID: String(100)  @title: 'SUB_COOWNER_ID' ;
        //     SUB_COOWNER_NAME: String(100)  @title: 'SUB_COOWNER_NAME' ;
        //     SUB_LEASE: String(5)  @title: 'SUB_LEASE' ;
        // SUB_PROGRAME_NAME                         : String(100)           @title: '{i18n>subprogramName}' ;
        // SUPPLY_TYPE                               : String(50)            @title: '{i18n>supplyType}';
        // TECHNICAL_CONTACT_EMAIL                   : String(80)            @title: '{i18n>technicalContacMail}' ;
        // TECHNICAL_CONTACT_NAME                    : String(100)           @title: '{i18n>technicalContactName}' ;
        // TECHNICAL_CONTACT_PHONE                   : String(20)            @title: '{i18n>technicalContactPhone}' ;
        // TECHNICAL_DOCUMENTS_SEND_TO_LANDLORD      : String(100)           @title: '{i18n>tecDocLandord}';
        // TECHNICAL_DOCUMENTS_SEND_TO_LANDLORD_DATE : Timestamp             @title: '{i18n>tecDocLandordDate}';
        //     TLR_COMUNITY_PERMISSION: String(100)  @title: 'TLR_COMUNITY_PERMISSION' ;
        //     TLR_COMUNITY_RELATIONS: String(100)  @title: 'TLR_COMUNITY_RELATIONS' ;
        TOTAL_COST                                : Double                @title: '{i18n>totalCost}';
        // TOTAL_DURATION                            : Integer               @title: '{i18n>totalDuration}';
        //     VALID_UNTIL_TO: Timestamp  @title: 'VALID_UNTIL_TO' ;
        // VALIDATE                                  : String(100)           @title: '{i18n>validation}';
        // VALIDATION_DATE                           : Timestamp             @title: '{i18n>validationDate}';
        // WHO_IS_THE_RESPONSIBLE                    : String(100)           @title: '{i18n>responsible}' ;
        // WHO_SIGNS_THE_CONTRACT_WITH_LAND_LORD     : String(100)           @title: 'WHO_SIGNS_THE_CONTRACT_WITH_LAND_LORD';
        // WHO_WILL_BUILD_THE_SITE                   : String(100)           @title: 'WHO_WILL_BUILD_THE_SITE';
        // CIVIL_WORK_ADAPTATIONS                    : String(100)           @title: '{i18n>civilWorkAdaptionsNeeded}';
        // CIVIL_WORK_ADAPTATIONS_DESC               : String(100)           @title: '{i18n>civilWorkAdaptions}';
        // COLLING_FEASIBILTY                        : String(100)           @title: '{i18n>coolingfeasibility}';
        // CONNECTIVITY_ADAPTATIONS                  : String(100)           @title: '{i18n>connectivityNeeded}';
        // CONNECTIVITY_ADAPTATIONS_DESC             : String(100)           @title: '{i18n>connectivityAdaptions}';
        // CONNECTIVITY_FEASIBILITY                  : String(100)           @title: '{i18n>connectivityFeasibility}';
        //     CONNECTIVITY_FEASIBILITY_RISK: String(100)  @title: 'CONNECTIVITY_FEASIBILITY_RISK' ;
        // COOLING_ADAPTATIONS                       : String(100)           @title: '{i18n>coolingNeeded}';
        // COOLING_ADAPTATIONS_DESC                  : String(100)           @title: '{i18n>coolingAdaptions}';
        //     COOLING_FEASIBILITY_RISK: String(100)  @title: 'COOLING_FEASIBILITY_RISK' ;
        // ELECTROMAGNETIC_FEASIBILITY               : String(100)           @title: '{i18n>electroFeasibility}';
        //     ELECTROMAGNETICENERGY_ADAPTATIONS_FEASIBILITY_RISK: String(100)  @title: 'ELECTROMAGNETIC_FEASIBILITY_RISK' ;
        // ENERGY_ADAPTATIONS                        : String(100)           @title: '{i18n>energyNeeded}';
        // ENERGY_ADAPTATIONS_DESC                   : String(100)           @title: '{i18n>energyAdaptions}';
        // ENERGY_FEASIBILITY                        : String(100)           @title: '{i18n>energyFeasibility}';
        //     ENERGY_FEASIBILITY_RISK: String(100)  @title: 'ENERGY_FEASIBILITY_RISK' ;
        // HEALTH_SAFETY_ADAPTATIONS                 : String(100)           @title: '{i18n>healthNeeded}';
        // HEALTH_SAFETY_FEASIBILITY                 : String(100)           @title: '{i18n>healthFeasibility}';
        //     HEALTH_SAFETY_FEASIBILITY_RISK: String(100)  @title: 'HEALTH_SAFETY_FEASIBILITY_RISK' ;
        // INFRASTRUCTURE_ADAPTATIONS                : String(100)           @title: '{i18n>infraAdaptionsNeeded}';
        // INFRASTRUCTURE_ADAPTATIONS_DESC           : String(100)           @title: '{i18n>infraAdaptions}';
        // INFRASTRUCTURE_FEASIBILITY_RISK           : String(100)           @title: '{i18n>infraFeasibilityRisk}';
        // INFRASTRUCTURE_FEASIBILITY                : String(100)           @title: '{i18n>infraFeasibility}';
        //     MARKETABLE: String(100)  @title: 'MARKETABLE' ;
        //     MARKETABLEID: String(100)  @title: 'MARKETABLEID' ;
        // MON_CTL_ADAPTATIONS                       : String(100)           @title: '{i18n>controlNeeded}';
        // MON_CTL_ADAPTATIONS_DESC                  : String(100)           @title: '{i18n>controlAdaptions}';
        // MON_CTL_FEASIBILITY                       : String(100)           @title: '{i18n>controlFeasibility}';
        //     MON_CTL_FEASIBILITY_RISK: String(100)  @title: 'MON_CTL_FEASIBILITY_RISK' ;
        //     OLD_REQUEST_ID: String(36)  @title: 'OLD_REQUEST_ID' ;
        OVERALL_FEASIBILITY                       : String(100)           @title: '{i18n>overallFeasibility}';
        OVERALL_FEASIBILITY_RISK                  : String(100)           @title: '{i18n>overAllFeasibilityRisk}';
        //     PERMITS_ADAPTATIONS: String(100)  @title: 'PERMITS_ADAPTATIONS' ;
        PERMITS_FEASIBILITY                       : String(100)           @title: '{i18n>permitsFeasibility}';
        // PERMITS_FEASIBILITY_RISK: String(100)                           @title: '{i18n>permitsFeasinilityRisk}' ;
        PERMITS_FEASIBILITY_EXPLANATION           : Integer               @title: '{i18n>permitsFeasibilityExplanation}';
        REAL_ESTATE_FEASIBILITY                   : String(100)           @title: '{i18n>realStateFeasibility}';
        REAL_ESTATE_FEASIBILITY_RISK              : String(100)           @title: '{i18n>realStateFeasibilityRisk}';
        //     RISK: String(100)  @title: 'RISK' ;
        //     TLR_PLANNING_PERM: String(100)  @title: 'TLR_PLANNING_PERM' ;
        //     ACTIVADED: Boolean  @title: 'ACTIVADED' ;
        //     ASSIGNED_AGENT: String(100)  @title: 'ASSIGNED_AGENT' ;
        //     RESPONSIBLE_AGENT: String(100)  @title: 'RESPONSIBLE_AGENT' ;
        //     COOLING_FEASIBILITY: String(100)  @title: 'COOLING_FEASIBILITY' ;
        //     UPDATING_DONE: String(5)  @title: 'UPDATING_DONE' ;
        UPDATE_INVENTORY                          : String(20)            @title: '{i18n>confirmInventoryUpdate}';
        //     COLOCATION_MANAGER: String(20)  @title: 'COLOCATION_MANAGER' ;
        //     MODIFIEDBULK_AT: Timestamp  @title: 'MODIFIEDBULK_AT' ;
        //     MODIFIEDBULK_BY: String(100)  @title: 'MODIFIEDBULK_BY' ;
        //     CREATEDBULK_AT: Timestamp  @title: 'CREATEDBULK_AT' ;
        //     CREATEDBULK_BY: String(100)  @title: 'CREATEDBULK_BY' ;
        //     DELETEDBULK_AT: Timestamp  @title: 'DELETEDBULK_AT' ;
        //     DELETEDBULK_BY: String(100)  @title: 'DELETEDBULK_BY' ;
        FORECAST_NA                              : Boolean default false  @title: 'FORECAST_NA' ;
        //     BLOCK_OPERATION_STATUS: Integer  @title: 'BLOCK_OPERATION_STATUS' ;
        //     ENLARGEMENT_TECHNICAL_ZONE_NEEDED: Integer  @title: 'ENLARGEMENT_TECHNICAL_ZONE_NEEDED: ENLARGEMENT OF THE TECHNICAL ZONE NEEDED' ;
        //     OTHER_SPECIFIC_WORKS_NEEDED: Integer  @title: 'OTHER_SPECIFIC_WORKS_NEEDED: OTHER SPECIFIC WORKS NEEDED' ;
        //     ADAPTIONS_OUTSIDE_WORKING_HOURS: Integer  @title: 'ADAPTIONS_OUTSIDE_WORKING_HOURS: ADAPTIONS TO BE PERFORMED OUTSIDE WORKING HOURS' ;
        //     CUTOFF_NEEDED: Integer  @title: 'CUTOFF_NEEDED: CUT OFF REQUEST' ;
        //     LANDSCAPE_INTEGRATION: Integer  @title: 'LANDSCAPE_INTEGRATION: LANDSCAPE INTEGRATION' ;
        //     COST_ESTIMATION_RANGE: Integer  @title: 'COST_ESTIMATION_RANGE: COST ESTIMATION RANGE' ;
        //     DELIVERY_PLANNED_DATE: Timestamp  @title: 'DELIVERY_PLANNED_DATE: PLANNED DATE OF DELIVERY' ;
        //     POWER_SUPPLY_REQUIRED: Integer  @title: 'POWER_SUPPLY_REQUIRED: POWER SUPPLY REQUIRED' ;
        //     COMPLETION_PRE_STUDY_REAL_ESTATE: Integer  @title: 'COMPLETION_PRE_STUDY_REAL_ESTATE: COMPLETION PRE STUDY REAL ESTATE' ;
        //     COMPLETION_PRE_STUDY_PERMITS: Integer  @title: 'COMPLETION_PRE_STUDY_PERMITS: COMPLETION PRE STUDY PERMITS' ;
        //     COMPLETION_PRE_STUDY_TECHNICAL: Integer  @title: 'COMPLETION_PRE_STUDY_TECHNICAL: COMPLETION PRE STUDY TECHNICAL' ;
        //     COMPLETION_PRE_STUDY_ENERGY: Integer  @title: 'COMPLETION_PRE_STUDY_ENERGY: COMPLETION PRE STUDY ENERGY' ;
        //     COMPLETION_PRE_STUDY_COOLING: Integer  @title: 'COMPLETION_PRE_STUDY_COOLING: COMPLETION PRE STUDY COOLING' ;
        //     ESTIMATED_BUDGET: String(100)  @title: 'ESTIMATED_BUDGET: ESTIMATED BUDGET' ;
        //     AGREED_WITH_CUST_TO_START_DATE: Timestamp  @title: 'AGREED_WITH_CUST_TO_START_DATE: DATE AGREED WITH CUSTOMER TO START' ;
        //     EXISTING_LANDSCAPE_INTEGRATION: Integer  @title: 'EXISTING_LANDSCAPE_INTEGRATION: EXISTING LANDSCAPE INTEGRATION ON SITE' ;
        //     CRANE_NEEDED                              : Integer               @title: '{i18n>craneNeeded}';
        //     STRUCTURAL_REINFORCEMENT_NEEDED: Integer  @title: 'STRUCTURAL_REINFORCEMENT_NEEDED: STRUCTURAL REINFORCEMENT NEEDED' ;
        //     MASSIVE_REINFORCEMENT_NEEDED: Integer  @title: 'MASSIVE_REINFORCEMENT_NEEDED: MASSIF REINFORCEMENT NEEDED' ;
        //     OTHER_MNOS_EQUIPMENTS_TO_MOVED: Integer  @title: 'OTHER_MNOS_EQUIPMENTS_TO_MOVED: OTHER MNOS EQUIPMENTS TO BE MOVED' ;
        //     MACRO_LEVEL_COST_ADAPTIONS_CRVT: String(100)  @title: 'MACRO_LEVEL_COST_ADAPTIONS_CRVT: MACRO LEVEL COST ESTIMATION FOR ADAPTIONS CRVT_STATUS' ;
        //     MACRO_LEVEL_COST_ADAPTIONS_EBF: Integer  @title: 'MACRO_LEVEL_COST_ADAPTIONS_EBF: MACRO LEVEL COST ESTIMATION FOR ADAPTIONS EBF STATUS' ;
        //     HS_MISSION_NEEDED: Integer  @title: 'HS_MISSION_NEEDED: HS MISSION NEEDED' ;
        //     APS_NEEDED: Integer  @title: 'APS_NEEDED: APS NEEDED' ;
        //     CALCULATION_REPORT_NEEDED: Integer  @title: 'CALCULATION_REPORT_NEEDED: CALCULATION REPORT NEEDED' ;
        //     SUBCONTRACTOR_QUOTATION_NEEDED: Integer  @title: 'SUBCONTRACTOR_QUOTATION_NEEDED: SUBCONTRACTOR QUOTATION NEEDED' ;
        //     PERMITS_EXPECTED_DATE: Timestamp  @title: 'PERMITS_EXPECTED_DATE: EXPECTED DATE PERMITS ROADMAP' ;
        //     RENEGO_EXPECTED_DATE: Timestamp  @title: 'RENEGO_EXPECTED_DATE: EXPECTED DATE RENEGO ROADMAP' ;
        //     OTHER_TECHNICAL_STUDY_NEEDED: Integer  @title: 'OTHER_TECHNICAL_STUDY_NEEDED: OTHER TECHNICAL STUDY NEEDED' ;
        //     DETAIL: String(100)  @title: 'DETAIL: DETAIL OF KICK OFF OF TECHNICAL AND COST ANALISYS' ;
        //     APD_DELIVERY_EXPECTED_DATE                  : Timestamp  @title: 'APD_DELIVERY_EXPECTED_DATE: EXPECTED DATE APD DELIVERY ROADMAP' ;
        //     CUST_PO_RECEPTION_EXPECTED_DATE: Timestamp  @title: 'CUST_PO_RECEPTION_EXPECTED_DATE: EXPECTED DATE CUSTOMER PO RECEPTION ROADMAP' ;
        //     MAD_EXPECTED_DATE: Timestamp  @title: 'MAD_EXPECTED_DATE: EXPECTED DATE MAD ROADMAP' ;
        APS_DELIVERY_EXPECTED_DATE                  : Timestamp  @title: 'APS_DELIVERY_EXPECTED_DATE: EXPECTED DATE APS DELIVERY' ;
        APD_PACK_DELIVERY_EXPECTED_DATE             : Timestamp  @title: 'APD_PACK_DELIVERY_EXPECTED_DATE: EXPECTED DATE APD PACKAGE DELIVERY' ;
        APD_PACK_DELIVERY_PLANNED_DATE              : Timestamp  @title: 'APD_PACK_DELIVERY_PLANNED_DATE: APD PACKAGE DELIVERY PLANNED DATE' ;
        APS_DELIVERY_PLANNED_DATE                   : Timestamp  @title: 'APS_DELIVERY_PLANNED_DATE: APS DELIVERY PLANNED DATE' ;
        HS_VISIT_PLANNED_DATE                       : Timestamp  @title: 'HS_VISIT_PLANNED_DATE: PLANNED DATE HS VISIT' ;
        HS_VISIT_DATE                               : Timestamp  @title: 'HS_VISIT_DATE: HS VISIT DATE' ;
        //     SPECIFIC_TECHNICAL_STUDIES: Integer  @title: 'SPECIFIC_TECHNICAL_STUDIES: IS THERE A NEED FOR SPECIFIC TECHNICAL STUDIES' ;
        //     TOWER_CONSTRUCTOR: Integer  @title: 'TOWER_CONSTRUCTOR: TOWER CONSTRUCTOR' ;
        //     LANDSCAPE_INTEGRATOR: Integer  @title: 'LANDSCAPE_INTEGRATOR: LANDSCAPE INTEGRATOR' ;
        ENERGY_PROVIDER_DOC_DELIVERY_EXPECTED_DATE  : Timestamp  @title: '{i18n>energyProvDocExpectedDate}' ;
        ENERGY_PROVIDER_VISIT_EXPECTED_DATE         : Timestamp  @title: '{i18n>energyProvVisitExpectedDate}' ;
        ENERGY_PROVIDER_VISIT_DATE                  : Timestamp  @title: '{i18n>energyProviderVisitDate}' ;
        //     GO_NO_GO: Integer  @title: 'GO_NO_GO: GO OR NO GO' ;
        KICK_OFF_ESTIMATED_VISIT_DATE               : Timestamp  @title: 'KICK_OFF_ESTIMATED_VISIT_DATE: KICK OFF ESTIMATED VISIT DATE' ;
        GLOBAL_START_WORKS_DATE                     : Timestamp  @title: 'GLOBAL_START_WORKS_DATE: START WORK DATE GLOBAL' ;
        GLOBAL_END_WORKS_DATE                       : Timestamp  @title: 'GLOBAL_END_WORKS_DATE: END WORK DATE GLOBAL' ;
        // CRANE_START_DATE                          : Timestamp             @title: '{i18n>craneStartDate}';
        // CRANE_END_DATE                            : Timestamp             @title: '{i18n>craneEndDate}';
        // END_ENERGY_ADAP_SIGN_CUSTOMER_DATE        : Timestamp             @title: '{i18n>madEnergyDate}';
        //     PRE_ENERGY_WORKS_START_DATE: Timestamp  @title: 'PRE_ENERGY_WORKS_START_DATE: PRELIMINARY ENERGY WORKS START DATE' ;
        //     PRE_ENERGY_WORKS_END_DATE: Timestamp  @title: 'PRE_ENERGY_WORKS_END_DATE: PRELIMINARY ENERGY WORKS END DATE' ;
        // ANTENNA_OUTAGE_START_DATE                 : Timestamp             @title: '{i18n>antennaOutageStart}' ;
        // ANTENNA_OUTAGE_END_DATE                   : Timestamp             @title: '{i18n>antennaOutageEnd}' ;
        EXPECTED_MAD_DATE                           : Timestamp             @title: '{i18n>expectedMadDate}';
        // ENERGY_PROVIDER_PAYMENT_DATE              : Timestamp             @title: '{i18n>energyDisPaymentDate}';
        // ENERGY_PROVIDER_EXPECTED_START_DATE       : Timestamp             @title: '{i18n>energyDisExpectedStartDate}';
        // ENERGY_PROVIDER_EXPECTED_END_DATE         : Timestamp             @title: '{i18n>energyDisExpectedDate}';
        // ENERGY_PROVIDER_ADAPT_START_DATE          : Timestamp             @title: '{i18n>energyDisStartDate}';
        // ENERGY_PROVIDER_ADAPT_END_DATE            : Timestamp             @title: '{i18n>energyDisEndDate}';
        // COOLING_TYPE                              : Integer               @title: '{i18n>coolingType}';
        // COOLING_END_DATE                          : Timestamp             @title: '{i18n>expectedCoolingEndDate}';
        INFRASTRUCTURES_MAD_DATE                    : Timestamp             @title: '{i18n>infraMadDate}' ;
        // EFFECTIVE_MAD_DATE                        : Timestamp             @title: '{i18n>effectiveMadDate}';
        // MAD_VISIT_DATE                            : Timestamp             @title: '{i18n>madVisitDate}';
        //     REAL_VT_DATE: Timestamp  @title: 'REAL_VT_DATE: REAL DATE VT FINAL VALIDATION' ;
        SUBCONTRACTOR_TYPE                          : Integer               @title: '{i18n>subcontractorType}';
        //     PRESTATION_CODE: String(20)  @title: 'PRESTATION_CODE' ;
        AMOUNT_BUDGET                               : Double                @title: '{i18n>expectedAmount}' ;
        // INFRA_ADAPTION_CLASSIFICATION             : Integer               @title: '{i18n>infraAdaptionClassif}';
        //     VISIT_DATE: Timestamp  @title: 'VISIT_DATE: GAP-3408 VISIT DATE' ;
        // FEASIBILITY_RESULT_EXPLANATION            : Integer               @title: '{i18n>feasibilityResult}';
        // new fields for BTS
        // CANDIDATE_PRIORITY                        : Integer               @title: '{i18n>candidatePriority}';
        // CUSTOMER_SHARED                           : Boolean               @title: '{i18n>customerShared}';
        // CANDIDATE_CHOSEN                          : Boolean default false @title: '{i18n>chosen}';
        // CANDIDATE_PROCEED                         : Boolean default false @title: '{i18n>proceed}';
        // INVENTORY_UPDATE_RESP                     : String(60)            @title: '{i18n>confirmInventoryUpdateResp}';
        // KICK_OFF_DESC                             : String(250)           @title: '{i18n>kickOffDescription}';
        //  ELECTROMAGNETIC_ADAPATIONS_DESC: String(100)               @title: '{i18n>electroAdaptions}';
        // CONNECTIVITY_TYPE                         : Integer               @title: '{i18n>connectivityType}';
        // LOS_ANALYSIS_REQUIRED                     : Integer               @title: '{i18n>losRequired}';
        // TOWER_HEIGHT                              : Double                @title: '{i18n>towerHeight}';
        // TOWER_TYPOLOGY                            : Integer               @title: '{i18n>towerTypology}';
        // HARDWARE_ORDERED_AT                       : Timestamp             @title: '{i18n>hardwareOrderedAt}';
        // HARDWARE_RECEIVED_AT                      : Timestamp             @title: '{i18n>hardwareReceivedAt}';
        // INSTALL_POWER_CONNECTION_AT               : Timestamp             @title: '{i18n>installPowerConnectionAt}';
        // PA_COMPLETE_AT                            : Timestamp             @title: '{i18n>paCompleteAt}';
        DEBTOR                                    : String(10)            @title: '{i18n>debtor}';
        ESTIMATED_PAYMENT_DATE                    : Timestamp             @title: '{i18n>estimatedPaymentDate}';
        READY_TO_START_WORKS_DATE                 : Timestamp             @title: '{i18n>readyToStartWorksDate}';
        REAL_ESTATE_FEASIBILITY_EXPLANATION       : Integer               @title: '{i18n>realEstateFeasibilityExplanation}';
        virtual ASSIGNED_RESPONSIBLE_FC           : UInt8 default 3;
        virtual SUBCONTRACTOR_TYPE_FC             : UInt8 default 3;
        virtual PROVIDER_NAME_FC                  : UInt8 default 3;
        virtual RESPONSIBLE_PERSON_FC             : UInt8 default 3;
        virtual activationReasonFC                : UInt8 default 3;
        virtual acceptedDateFC                    : UInt8 default 3;
        virtual acceptedFC                        : UInt8 default 3;
        virtual adaptionsTypeFC                   : UInt8 default 3;
        virtual amountFC                          : UInt8 default 3;
        virtual apdPackDeliveryExpectedDateFC     : UInt8 default 3; 
        virtual apdPackDeliveryPlannedDateFC      : UInt8 default 3;
        virtual apsDeliveryExpectedDateFC         : UInt8 default 3;
        virtual apsDeliveryPlannedDateFC          : UInt8 default 3;
        // virtual agencyContactFC                   : UInt8 default 3;
        // virtual agencyContactMailFC               : UInt8 default 3;
        virtual automaticManualResponseFC         : UInt8 default 3;
        virtual completedByFC                     : UInt8 default 3;
        virtual completedDateFC                   : UInt8 default 3;
        virtual complexityFC                      : UInt8 default 3;
        virtual confirmInventoryUpdateFC          : UInt8 default 3;
        virtual confirmInventoryUpdateRespFC      : UInt8 default 3;
        virtual contractRestrictionsFC            : UInt8 default 3;
        virtual currencyFC                        : UInt8 default 3;
        virtual debtorFC                          : UInt8 default 3;
        virtual descriptionFC                     : UInt8 default 3;
        virtual energyProvDocExpectedDateFC       : UInt8 default 3;
        virtual energyProvVisitExpectedDateFC     : UInt8 default 3;
        virtual energyProviderVisitDateFC         : UInt8 default 3;
        virtual expectedDateFC                    : UInt8 default 3;
        virtual expectedMadDateFC                 : UInt8 default 3;
        virtual expectedStartDateFC               : UInt8 default 3;
        virtual expectedEndDateFC                 : UInt8 default 3;
        virtual estimatedPaymentDateFC            : UInt8 default 3;
        virtual readyToStartWorksDateFC           : UInt8 default 3;
        virtual globalStartWorksDateFC            : UInt8 default 3;
        virtual globalEndWorksDateFC              : UInt8 default 3;
        virtual heritageEndDateFC                 : UInt8 default 3;
        virtual hsVisitDateFC                     : UInt8 default 3;
        virtual hsVisitPlannedDateFC              : UInt8 default 3;
        virtual infraMadDateFC                    : UInt8 default 3;
        virtual kickOffDescriptionFC              : UInt8 default 3;
        virtual kickOffEstimatedVisitDateFC       : UInt8 default 3;
        virtual kickOffRealDateFC                 : UInt8 default 3;
        virtual kickOffVisitNeededFC              : UInt8 default 3;
        virtual madResultFC                       : UInt8 default 3;
        virtual permitsFeasibilityExpFC           : UInt8 default 3;
        virtual permitsFeasibilityFC              : UInt8 default 3;
        virtual permitsNeededFC                   : UInt8 default 3;
        virtual plannedDateFC                     : UInt8 default 3;
        virtual plannedKickoffDateFC              : UInt8 default 3;
        virtual realStateFeasibilityFC            : UInt8 default 3;
        virtual realStateFeasibilityRiskFC        : UInt8 default 3;
        virtual realEstateFeasibilityExpFC        : UInt8 default 3;
        virtual realStartDateFC                   : UInt8 default 3;
        virtual realEndDateFC                     : UInt8 default 3;
        virtual rejectionReasonFC                 : UInt8 default 3;
        virtual renegoNeededFC                    : UInt8 default 3;
        virtual repaymentStatusFC                 : UInt8 default 3;
        virtual sendOfferDateFC                   : UInt8 default 3;
        virtual siteSurveyDateFC                  : UInt8 default 3;
        virtual siteSurveyWillBeNeededFC          : UInt8 default 3;
        virtual startDateFC                       : UInt8 default 3;
        virtual totalCostFC                       : UInt8 default 3;
        virtual totalCostClientFC                 : UInt8 default 3;
        virtual newUploadTableEnabled             : Boolean default false;
        // virtual overallFeasibilityFC              : UInt8 default 3;
        // virtual overallFeasibilityRiskFC          : UInt8 default 3;
        // virtual areExtraordinaryCostFC            : UInt8 default 3;
        // virtual extraCostAmountFC                 : UInt8 default 3;
        // virtual extraCurrencyFC                   : UInt8 default 3;
        // virtual exceedSLAFC                       : UInt8 default 3;
        // virtual managerValidationFC               : UInt8 default 3;
        // virtual managerValidationDateFC           : UInt8 default 3;
        // virtual feasibilityResultFC               : UInt8 default 3;
        // virtual civilWorkAdaptionsNeededFC        : UInt8 default 3;
        // virtual civilWorkAdaptionsFC              : UInt8 default 3;
        // virtual infraAdaptionsNeededFC            : UInt8 default 3;
        // virtual infraAdaptionsFC                  : UInt8 default 3;
        // virtual infraFeasibilityFC                : UInt8 default 3;
        // virtual infraFeasibilityRiskFC            : UInt8 default 3;
        // virtual scatCategoryFC                    : UInt8 default 3;
        // virtual energyFeasibilityFC               : UInt8 default 3;
        // virtual energyNeededFC                    : UInt8 default 3;
        // virtual energyAdaptionsFC                 : UInt8 default 3;
        // virtual coolingFeasibilityFC              : UInt8 default 3;
        // virtual coolingNeededFC                   : UInt8 default 3;
        // virtual coolingAdaptionsFC                : UInt8 default 3;
        // virtual electroFeasibilityFC              : UInt8 default 3;
        // virtual electroAdaptionsFC                : UInt8 default 3;
        // virtual connectivityFeasibilityFC         : UInt8 default 3;
        // virtual connectivityNeededFC              : UInt8 default 3;
        // virtual connectivityAdaptionsFC           : UInt8 default 3;
        // virtual controlFeasibilityFC              : UInt8 default 3;
        // virtual controlNeededFC                   : UInt8 default 3;
        // virtual controlAdaptionsFC                : UInt8 default 3;
        // virtual healthFeasibilityFC               : UInt8 default 3;
        // virtual healthNeededFC                    : UInt8 default 3;
        // virtual providerNameFC                    : UInt8 default 3;
        // virtual providerMailFC                    : UInt8 default 3;
        // virtual providerPhoneFC                   : UInt8 default 3;
        // virtual infraAdaptionClassifFC            : UInt8 default 3;
        // virtual meterBoxDateFC                    : UInt8 default 3;
        // virtual preTipinFC                        : UInt8 default 3;
        // virtual powerConnectedDateFC              : UInt8 default 3;
        // virtual supplyTypeFC                      : UInt8 default 3;
        // virtual confirmTxDateFC                   : UInt8 default 3;
        // virtual tecDocLandordFC                   : UInt8 default 3;
        // virtual tecDocLandordDateFC               : UInt8 default 3;
        // virtual craneNeededFC                     : UInt8 default 3;
        // virtual craneStartDateFC                  : UInt8 default 3;
        // virtual craneEndDateFC                    : UInt8 default 3;
        // virtual adaptionsOkFC                     : UInt8 default 3;
        // virtual energyDisPaymentDateFC            : UInt8 default 3;
        // virtual energyDisExpectedStartDateFC      : UInt8 default 3;
        // virtual energyDisExpectedDateFC           : UInt8 default 3;
        // virtual energyDisStartDateFC              : UInt8 default 3;
        // virtual energyDisEndDateFC                : UInt8 default 3;
        // virtual madEnergyDateFC                   : UInt8 default 3;
        // virtual effectiveMadDateFC                : UInt8 default 3;
        // virtual madVisitDateFC                    : UInt8 default 3;
        // virtual adaptionsCheckTypeFC              : UInt8 default 3;
        // virtual coolingTypeFC                     : UInt8 default 3;
        // virtual expectedCoolingEndDateFC          : UInt8 default 3;
        // virtual whoIsResponsibleFC                : UInt8 default 3;
        // virtual connectivityTypeFC                : UInt8 default 3;
        // virtual losRequiredFC                     : UInt8 default 3;
        // virtual towerHeightFC                     : UInt8 default 3;
        // virtual towerTypologyFC                   : UInt8 default 3;
        // virtual accountManagerNameFC              : UInt8 default 3;
        // virtual accountManagerMailFC              : UInt8 default 3;
        // virtual accountManagerPhoneFC             : UInt8 default 3;
        // virtual technicalContactNameFC            : UInt8 default 3;
        // virtual technicalContacMailFC             : UInt8 default 3;
        // virtual technicalContactPhoneFC           : UInt8 default 3;
        // virtual hardwareOrderedAtFC               : UInt8 default 3;
        // virtual hardwareReceivedAtFC              : UInt8 default 3;        
        // virtual installPowerConnectionAtFC        : UInt8 default 3;                
        // virtual paCompleteAtFC                    : UInt8 default 3;
        // virtual subprogramNameFC                  : UInt8 default 3;
        // virtual elapsedTimeFC                     : UInt8 default 3;
        // virtual strengthCalcCostRequestDateFC     : UInt8 default 3;      
        // virtual strengthCalcCostApprovalDateFC    : UInt8 default 3;           
        // virtual providerUserNameFC                : UInt8 default 3;
        // virtual strengtheninigAgreedFC            : UInt8 default 3;
        // virtual antennaOutageStartFC              : UInt8 default 3;      
        // virtual antennaOutageEndFC                : UInt8 default 3;
        // virtual planningRatingFC                  : UInt8 default 3;
        // virtual priorityAssesmentCompleteFC       : UInt8 default 3;
} 
 
@cds.persistence.exists
entity DOCUMENTS_PER_BLOCK {
    key REGISTER_ID                        : String(36)            @title        : '{i18n>ID}';
        BLOCK_ID                           : String(36)            @title        : '{i18n>blockId}';
        CREATEDAT                          : Timestamp             @title        : '{i18n>createdAt}';
        CREATEDBY                          : String(100)           @title        : '{i18n>createdBy}';
        DELETED                            : Boolean               @title        : '{i18n>deleted}';
        DELETED_AT                         : Timestamp             @title        : '{i18n>deletedAt}';
        DELETED_BY                         : String(100)           @title        : '{i18n>deletedBy}';
        //DOC_PB_ID: String(36)                       @title: 'DOC_PB_ID' ;
        MODIFIEDAT                         : Timestamp             @title        : '{i18n>modifiedAt}';
        MODIFIEDBY                         : String(100)           @title        : '{i18n>modifiedBy}';
        ORDER                              : Integer               @title        : '{i18n>order}';
        RESPONSIBLE_ID                     : String(36)            @title        : '{i18n>responsibleId}';
        SUBCONTRATOR_ID                    : String(36)            @title        : '{i18n>subcontractorId}';
        //T_DOC_CREATED_DATE: Timestamp               @title: 'T_DOC_CREATED_DATE' ;
        //T_DOC_CREATEDBY: String(100)                @title: 'T_DOC_CREATEDBY' ;
        //T_DOC_EXPIRATION_DATE: Timestamp            @title: 'T_DOC_EXPIRATION_DATE' ;
        T_DOC_ID: String(36)                            @title: 'relationshipId' ;
        //T_DOC_NAME: String(255)                     @title: 'T_DOC_NAME' ;
        //T_DOC_SUBTYPE: String(50)                   @title: 'T_DOC_SUBTYPE' ;
        //T_GO: Boolean                               @title: 'T_GO' ;
        T_RESPONSIBLE                      : String(100)           @title        : '{i18n>responsibleDefault}';
        //T_SUBCONTRACTOR: String(100)                @title: 'T_SUBCONTRACTOR' ;
        VALIDATION_CELLNEX_CLIENT          : String(10)            @title        : '{i18n>cellnexValidation}';
        VALIDATION_REQ_CLIENT              : String(10)            @title        : '{i18n>customerValidation}';
        VALIDATION_SUBCO_CLIENT            : String(10)            @title        : '{i18n>subcontratorValidation}';
        VALIDATION_SITEOWNER_NEEDED        : String(10)            @title        : '{i18n>siteOwnerValidation}';
        //TLR: String(20)                             @title: 'TLR' ;
        PERMIT_ID: String(36)                       @title: '{i18n>jointProjectId}' ;//MASTER_REQUEST_ID
        STEP_ID: String(16)                         @title: '{i18n>masterBlockId}' ;
        //ACTION: String(20)                          @title: 'ACTION' ;
        //DOCUMENT_TYPE: String(100)                  @title: '{i18n>document}' ;
        GENERIC_TYPE_ID                    : String(50)            @title        : '{i18n>documentId}';
        //ASSIGNED: String(50)                        @title: 'ASSIGNED' ;
        TYPE_ID: String(50)                          @title: 'TYPE_ID' ;
        STATUS                             : Integer @title: '{i18n>status}';
        WORK_ID                            : String(36)  @title: 'Work ID';
        //SHARED_DOCUMENT: String(3)                  @title: 'SHARED_DOCUMENT' ;
        //LOCKED: String(10)                          @title: 'LOCKED' ;
        //AMOUNT: Double                              @title: 'AMOUNT: CUSTOMER OFFER AND LICENCE ACCEPTANCE TOTAL AMOUNT' ;
        //CURRENCY: String(3)                         @title: 'CURRENCY' ;
        virtual cellnexResponsible              : String(50) @Core.Computed: false;
        virtual subcontractorResponsible        : String(50) @Core.Computed: false;    
        virtual agencyResponsible               : String(50) @Core.Computed: false;
        virtual customerResponsible             : String(50) @Core.Computed: false;    
        virtual cellnexResponsibleName          : String(200) @Core.Computed: false;
        virtual subcontractorResponsibleName    : String(200) @Core.Computed: false;    
        virtual agencyResponsibleName           : String(200) @Core.Computed: false;    
        virtual customerResponsibleName         : String(200) @Core.Computed: false;    
        virtual cellnexResponsibleFC            : UInt8 default 0;
        virtual subcontractorResponsibleFC      : UInt8 default 0;    
        virtual agencyResponsibleFC             : UInt8 default 0;    
        virtual customerResponsibleFC           : UInt8 default 0;    
        virtual approverTypeName           : String(200);
        virtual approverTypeFC             : UInt8 default 1;
        virtual subcoTypeName              : String(200);
        virtual subcoTypeFC                : UInt8 default 1;
        virtual responsibleDefaultName     : String(200);
        virtual responsibleDefaultFC       : UInt8 default 1;
        virtual cellnexValidationFC        : UInt8 default 1;
        virtual subcontractorValidationFC          : UInt8 default 1;
        virtual customerValidationFC       : UInt8 default 1;
        virtual siteOwnerValidationFC      : UInt8 default 1;
        virtual cellnexValidatorFC         : UInt8 default 1;
        virtual subcontractorValidatorFC           : UInt8 default 1;
        virtual customerValidatorFC        : UInt8 default 1;
        virtual siteOwnerValidatorFC       : UInt8 default 1;
        virtual documentIdFC               : UInt8 default 1;
        virtual Criticality                : UInt8 default 1;
        virtual stepIdVF                   : String(16)            @readonly;
        virtual statusIconVF               : String(20)            @readonly;
        virtual statusStateVF              : String(15)            @readonly;
        virtual statusTextVF               : String(50)            @readonly;
        virtual cellnexStatusIconVF        : String(20)            @readonly;
        virtual cellnexStatusStateVF       : String(15)            @readonly;
        virtual cellnexStatusTextVF        : String(50)            @readonly;
        virtual responsibleStatusIconVF    : String(20)            @readonly;
        virtual responsibleStatusStateVF   : String(15)            @readonly;
        virtual responsibleStatusTextVF    : String(50)            @readonly;
        virtual subcontractorStatusIconVF  : String(20)            @readonly;
        virtual subcontractorStatusStateVF : String(15)            @readonly;
        virtual subcontractorStatusTextVF  : String(50)            @readonly;
        virtual customerStatusIconVF       : String(20)            @readonly;
        virtual customerStatusStateVF      : String(15)            @readonly;
        virtual customerStatusTextVF       : String(50)            @readonly;
        virtual siteOwnerStatusIconVF      : String(20)            @readonly;
        virtual siteOwnerStatusStateVF     : String(15)            @readonly;
        virtual siteOwnerStatusTextVF      : String(50)            @readonly;
        virtual documentNameVF             : String(200);
        virtual siteOwnerValidationName    : String(200);
        virtual customerValidationName     : String(200);
        virtual subcontractorValidationName   : String(200);
        virtual cellnexValidationName      : String(200);
        virtual cellnexValidationVF        : Boolean default false @Core.Computed: false;
        virtual subcontractorValidationVF  : Boolean default false @Core.Computed: false;
        virtual customerValidationVF       : Boolean default false @Core.Computed: false;
        virtual siteOwnerValidationVF      : Boolean default false @Core.Computed: false;
        virtual cancellationReason         : String(2000) @title: '{i18n>cancellationReason}' @UI.MultiLineText;
        virtual canInit                     : Boolean default false;
        virtual canSee                      : Boolean default false;
        virtual canDelete                   : Boolean default false;
        virtual canDownload                 : Boolean default false;
}

@cds.persistence.exists
entity INSTANCES_PER_DOCUMENT {
    key REGISTER_ID                           : String(36)            @title: '{i18n>ID}';
        CELLNEX_COMMENT                       : String(2000)          @title: '{i18n>cellnexComments}';
        CELLNEX_VALIDATION                    : String(50)            @title: '{i18n>cellnexValidation}';
        CELLNEX_VALIDATION_DATE               : Timestamp             @title: '{i18n>cellnexValidationDate}';
        CELLNEX_VALIDATOR                     : String(50)            @title: '{i18n>cellnexValidator}';
        CONTACT_EMAIL                         : String(80)            @title: '{i18n>contactEmail}';
        CONTACT_PHONE                         : String(20)            @title: '{i18n>contactPhone}';
        CREATEDAT                             : Timestamp             @title: '{i18n>createdAt}';
        CREATEDBY                             : String(100)           @title: '{i18n>createdBy}';
        CUSTOMER_COMMENT                      : String(2000)          @title: '{i18n>clientComments}';
        CUSTOMER_VALIDATION                   : String(50)            @title: '{i18n>clientValidation}';
        CUSTOMER_VALIDATION_DATE              : Timestamp             @title: '{i18n>clientValidationDate}';
        CUSTOMER_VALIDATOR                    : String(50)            @title: '{i18n>clientValidator}';
        DELETED                               : Boolean               @title: '{i18n>deleted}';
        DELETED_AT                            : Timestamp             @title: '{i18n>deletedAt}';
        DELETED_BY                            : String(100)           @title: '{i18n>deletedBy}';
        DOC_PB_ID                             : String(36)            @title: '{i18n>jointProjectId}' ;
        DOCUMENT_ID_DOSSIER_ATTACHED          : String(36)            @title: '{i18n>requestCodeOrigin}' ;
        DOCUMENT_ID_SENT_CUSTOMER             : String(36)            @title: '{i18n>taskCompleted}' ;
        END_DATE                              : Timestamp             @title: '{i18n>endDate}';
        INSTANCE_ID                           : String(36)            @title: '{i18n>instanceId}';
        MODIFIEDAT                            : Timestamp             @title: '{i18n>modfiedAt}';
        MODIFIEDBY                            : String(100)           @title: '{i18n>modifiedBy}';
        SITEOWNER_COMMENT                     : String(2000)          @title: '{i18n>landlordComments}';
        SITEOWNER_VALIDATION                  : String(50)            @title: '{i18n>landlordValidation}';
        SITEOWNER_VALIDATION_DATE             : Timestamp             @title: '{i18n>landlordValidationDate}';
        SITEOWNER_VALIDATOR                   : String(50)            @title: '{i18n>landlordValidator}';
        START_DATE                            : Timestamp             @title: '{i18n>startDate}';
        SUBCONTRACTOR_COMMENT                 : String(2000)          @title: '{i18n>subcoComments}';
        SUBCONTRACTOR_VALIDATION              : String(50)            @title: '{i18n>subcontractorValidation}';
        SUBCONTRACTOR_VALIDATION_DATE         : Timestamp             @title: '{i18n>subcontractorValidationDate}';
        SUBCONTRACTOR_VALIDATOR               : String(50)            @title: '{i18n>subcontractorValidator}';
        SUBMISSION_DATE                       : Timestamp             @title: '{i18n>submissionDate}';
        T_GO                                  : Boolean               default false                    @title: '{i18n>tasksActivated}' ;
        VERSION                               : String(36)            @title: '{i18n>version}';
        BLOCK_ID                              : String(36)            @title: '{i18n>blockId}';
        STEP_ID                               : String(16)            @title: '{i18n>stepId}';
        STEP_TXT                              : String(500)           @title: '{i18n>stepName}';
        ASSIGNED_ROLE                         : String(50)            @title: '{i18n>role}';
        EXPECTED_SUBMISSION_DATE              : Timestamp             @title: '{i18n>expectedSubmissionDate}';
        EXPECTED_CUSTOMER_VAL                 : Timestamp             @title: '{i18n>expectedValidationDate}';
        EXPECTED_CELLNEX_VAL                  : Timestamp             @title: '{i18n>expectedValidationDate}';
        EXPIRATION_DATE                       : Timestamp             @title: '{i18n>expirationDate}';
        // EXPIRATION_DATE_MANDATORY: String(2)            @title: 'EXPIRATION_DATE_MANDATORY' ;
        DOCUMENT_RESPONSIBLE_ROL              : String(50)            @title: '{i18n>documentsResponsibleRole}';
        PLANNED_SUBMISSION_DATE               : Timestamp             @title: '{i18n>plannedSubmissiondate}';
        CANCELLATION_REASON                   : String(2000)          @title: '{i18n>cancellationReason}' @UI.MultiLineText;
        MODIFIEDBULK_AT                       : Timestamp             @title: '{i18n>modifiedBulkAt}';
        MODIFIEDBULK_BY                       : String(100)           @title: '{i18n>modifiedBulkBy}';
        CREATEDBULK_AT                        : Timestamp             @title: '{i18n>createdBulkAt}';
        CREATEDBULK_BY                        : String(100)           @title: '{i18n>createdBulkBy}';
        DELETEDBULK_AT                        : Timestamp             @title: '{i18n>deletedBulkAt}';
        DELETEDBULK_BY                        : String(100)           @title: '{i18n>deletedBulkBy}';
        ASSIGNED_RESPONSIBLE                  : String(100)           @title: '{i18n>assignedResponsible}';
        // GROUP_ASSIGNED_RESPONSIBLE: String(100)         @title: 'GROUP_ASSIGNED_RESPONSIBLE' ;
        SUBCO_ASSIGNED                        : String(100)           @title: '{i18n>assignedSubcontractor}';
        // SUBCO_GROUP_ASSIGNED: String(100)               @title: 'SUBCO_GROUP_ASSIGNED' ;
        FORECAST_NA                           : Boolean default false @title: '{i18n>forescast}';
        CUSTOMER_INFORM_DATE                  : Timestamp             @title: '{i18n>customerInformDate}';
        DOCUMENTS_RESPONSIBLE_COMMENTS        : String(2000)          @title: '{i18n>documentsResponsibleComments}';
        LIMIT_SUBMISSION_DATE                 : Timestamp             @title: '{i18n>limitSubmissionDate}' ;
        virtual contactEmailFC                : UInt8 default 1;
        virtual contactPhoneFC                : UInt8 default 1;
        virtual endDateFC                     : UInt8 default 1;
        virtual startDateFC                   : UInt8 default 1;
        virtual cellnexValidationCommentsFC   : UInt8 default 1;
        virtual subcontractorValidationCommentsFC     : UInt8 default 1;
        virtual customerValidationCommentsFC  : UInt8 default 1;
        virtual siteOwnerValidationCommentsFC : UInt8 default 1;
        virtual cellnexValidationDateFC       : UInt8 default 1;
        virtual subcontractorValidationDateFC : UInt8 default 1;
        virtual customerValidationDateFC      : UInt8 default 1;
        virtual siteOwnerValidationDateFC     : UInt8 default 1;
        virtual cellnexValidatorFC            : UInt8 default 1;
        virtual subcontractorValidatorName    : String(200);
        virtual subcontractorValidatorFC      : UInt8 default 1; 
        virtual customerValidatorName         : String(200);
        virtual customerValidatorFC           : UInt8 default 1;
        virtual siteOwnerValidatorName        : String(200);
        virtual siteOwnerValidatorFC          : UInt8 default 1;
        virtual cellnexValidatorName          : String(200);
        virtual cellnexValidationFC           : UInt8 default 1;
        virtual subcontractorValidationFC     : UInt8 default 1;
        virtual customerValidationFC          : UInt8 default 1;
        virtual siteOwnerValidationFC         : UInt8 default 1;
        virtual expectedSubmissionDateFC      : UInt8 default 1;
        virtual submissionDateFC              : UInt8 default 1;
        virtual expirationDateFC              : UInt8 default 1;
        virtual customerInformDateFC          : UInt8 default 1;
        virtual stepIdFC                      : UInt8 default 1;
        virtual approverTypeName              : String(200);
        virtual subcoTypeName                 : String(200);
        virtual responsibleDefaultNameVF      : String(200);
        virtual cellnexValidationVF           : Boolean default false @Core.Computed: false;
        virtual subcontractorValidationVF     : Boolean default false @Core.Computed: false;
        virtual customerValidationVF          : Boolean default false @Core.Computed: false;
        virtual siteOwnerValidationVF         : Boolean default false @Core.Computed: false;
        virtual blockIdVF                     : String(36);
        virtual buttonCompleteVF              : Boolean default false @Core.Computed: false;
        virtual documentIdVF                  : String(36);
        virtual documentNameVF                : String(36);
        virtual taskCodeFC                    : UInt8 default 3;
        virtual validatorFC                   : UInt8 default 3;
        virtual decisionFC                    : UInt8 default 3;
        virtual requestCodeOriginFC           : UInt8 default 3;
}

@cds.persistence.exists
entity WF_DETAIL_DOCUMENTS {
    key REGISTER_ID           : String(36)                       @title           : 'REGISTER_ID';
        BLOCK_ID              : String(36)                       @title           : 'BLOCK_ID';
        INSTANCE_ID           : String(36)                       @title           : 'INSTANCE_ID';
        REQUEST_ID            : String(36)                       @title           : 'REQUEST_ID';
        REQUEST_CODE          : String(100) not null             @title           : 'REQUEST_CODE';
        TYPE_ID               : String(50) not null              @title           : 'TYPE_ID';
        STEP_ID               : String(50) not null              @title           : 'STEP_ID';
        FIELD                 : String(50)                       @title           : 'FIELD';
        DOCUMENT_NAME         : String(1000)                     @title           : 'DOCUMENT_NAME';
        DOCUMENT_VERSION      : String(10)                       @title           : 'DOCUMENT_VERSION';
        DOCUMENT_URL          : String(250)                      @title           : 'DOCUMENT_URL';
        USER_DOC              : String(250)                      @title           : 'USER_DOC';
        CREATION_DATE_DOC     : String(50)                       @title           : 'CREATION_DATE_DOC';
        DOCUMENT_SUBTYPE      : String(100)                      @title           : 'DOCUMENT_SUBTYPE';
        DOCUMENT_SUBTYPE_LVL2 : String(500)                      @title           : 'DOCUMENT_SUBTYPE_LVL2';
        CREATEDAT             : Timestamp                        @title           : 'CREATEDAT';
        CREATEDBY             : String(100)                      @title           : 'CREATEDBY';
        DELETED               : Boolean                          @title           : 'DELETED';
        DELETED_AT            : Timestamp                        @title           : 'DELETED_AT';
        DELETED_BY            : String(100)                      @title           : 'DELETED_BY';
        MODIFIEDAT            : Timestamp                        @title           : 'MODIFIEDAT';
        MODIFIEDBY            : String(100)                      @title           : 'MODIFIEDBY';
        DOCUMENT_ID           : String(50)                       @title           : 'DOCUMENT_ID';
        OT_DOCUMENT_ID        : Integer                          @title           : 'OT_DOCUMENT_ID';
        BLOCK_NAME            : String(30)                       @title           : 'BLOCK_NAME';
        PHASE_NAME            : String(30)                       @title           : 'PHASE_NAME';
        FINAL_DOCUMENT        : Boolean                          @title           : 'FINAL_DOCUMENT';
        MEDIA_TYPE            : String(100) default 'text/plain' @Core.IsMediaType: true;
        WORK_ID               : String(36)                       @title           : 'Work ID';
        virtual documentTypeName : String(500)                   @title           : '{i18n>documentType}';
        virtual canDelete     : Boolean;
}

@cds.persistence.exists 
entity SC_SELECT_OPTIONS_V2 {
        SCREEN_RULE_ID: Integer  @title: 'SCREEN_RULE_ID' ; 
    key PHASE_ID_PK: String(50)  @title: 'PHASE_ID_PK' ; 
    key FIELD_ID: String(50)  @title: 'FIELD_ID' ; 
    key COUNTRY_ID: String(2)  @title: 'COUNTRY_ID' ; 
    key LANGUAGE: String(2)  @title: 'LANGUAGE' ; 
    key SELECT_OPTION_ID: Integer  @title: 'SELECT_OPTION_ID' ; 
        SELECT_OPTION: String(200)  @title: 'SELECT_OPTION' ; 
        PHASE_ID: String(50)  @title: 'PHASE_ID' ; 
    key PROCESS_ID_PK: String(50)  @title: 'PROCESS_ID_PK' ; 
        ACTIVE: Boolean  @title: 'ACTIVE' ; 
}

@cds.persistence.exists
entity SC_SELECT_OPTIONS_V3_MASTER {
    key SELECT_OPTION_ID : Integer     @title: 'SELECT_OPTION_ID: select option human id';
    key FIELD_ID         : String(50)  @title: 'FIELD_ID: field id';
        CREATEDAT        : Timestamp   @title: 'CREATEDAT';
        CREATEDBY        : String(255) @title: 'CREATEDBY';
        MODIFIEDAT       : Timestamp   @title: 'MODIFIEDAT';
        MODIFIEDBY       : String(255) @title: 'MODIFIEDBY';
        SELECT_OPTION    : String(200) @title: 'SELECT_OPTION: select option value';
}

@cds.persistence.exists
entity SC_SELECT_OPTIONS_V3_TRANSLATE {
    key FIELD_ID         : String(50)  @title: 'FIELD_ID: field id';
    key SELECT_OPTION_ID : Integer     @title: 'SELECT_OPTION_ID: select option human id';
    key LANGUAGE_ID      : String(2)   @title: 'LANGUAGE_ID: language id';
        CREATEDAT        : Timestamp   @title: 'CREATEDAT';
        CREATEDBY        : String(255) @title: 'CREATEDBY';
        MODIFIEDAT       : Timestamp   @title: 'MODIFIEDAT';
        MODIFIEDBY       : String(255) @title: 'MODIFIEDBY';
        SELECT_OPTION    : String(200) @title: 'SELECT_OPTION: select option value';
}

@cds.persistence.exists
entity SC_SELECT_OPTIONS_V3_CONFIGURATION {
    key SELECT_OPTION_ID : Integer          @title: 'SELECT_OPTION_ID: select option human id';
    key FIELD_ID         : String(50)       @title: 'FIELD_ID: field id';
    key COUNTRY_ID       : String(2)        @title: 'COUNTRY_ID: country id';
    key PROCESS_ID_PK    : String(50)       @title: 'PROCESS_ID_PK: process id';
        CREATEDAT        : Timestamp        @title: 'CREATEDAT';
        CREATEDBY        : String(255)      @title: 'CREATEDBY';
        MODIFIEDAT       : Timestamp        @title: 'MODIFIEDAT';
        MODIFIEDBY       : String(255)      @title: 'MODIFIEDBY';
        ACTIVE           : Boolean not null @title: 'ACTIVE: on/off';
}

@cds.persistence.exists
entity SC_SELECT_DEPENDENCES {
    key SELECT_OPTION_ID        : Integer       @title: 'Select option human id';
    key FIELD_ID                : String(50)    @title: 'Field id';
    key FIELD_DEPENDENCE_ID     : String(50)    @title: 'Dependent field id';
    key DEPENDENCE_OPTION_ID    : Integer       @title: 'Dependent select option human id';
}

@cds.persistence.exists
entity RESPONSIBLES_PER_REQUEST {
    key ID                 : String(36)  @title: 'ID';
    key REQUEST_ID         : String(36)  @title: 'REQUEST_ID';
    key BLOCK_ID           : String(36)  @title: 'BLOCK_ID';
        GENERIC_TYPE_ID    : String(36)  @title: 'GENERIC_TYPE_ID';
        APPROVER_TYPE      : Integer     @title: 'APPROVER_TYPE';
        SUBCONTRACTOR_TYPE : Integer     @title: 'SUBCONTRACTOR_TYPE';
        RESPONSIBLE        : String(100) @title: 'RESPONSIBLE';
        SUBCONTRACTOR      : String(100) @title: 'SUBCONTRACTOR';
        VALIDATION_TYPE    : Integer     @title: 'VALIDATION_TYPE';
        RESPONSIBLE_GROUP  : Integer     @title: 'RESPONSIBLE_GROUP';
        SUBCO_REQ_VAL      : Boolean     @title: 'SUBCO_REQ_VAL';
        CELNEX_REQ_VAL     : Boolean     @title: 'CELNEX_REQ_VAL';
        CUSTOMER_REQ_VAL   : Boolean     @title: 'CUSTOMER_REQ_VAL';
        SITEOWNER_REQ_VAL  : Boolean     @title: 'SITEOWNER_REQ_VAL';
        CREATEDBY          : String(255) @title: 'CREATEDBY';
        CREATEDAT          : Timestamp   @title: 'CREATEDAT';
        MODIFIEDAT         : Timestamp   @title: 'MODIFIEDAT';
        MODIFIEDBY         : String(255) @title: 'MODIFIEDBY';
        DELETEDBY          : String(255) @title: 'DELETEDBY';
        DELETEDAT          : Timestamp   @title: 'DELETEDAT';
}

@cds.persistence.exists
entity RESPONSIBLE_APPROVAL_FLOW {
    key APPROVER_TYPE      : Integer    @title: 'APPROVER_TYPE';
    key SUBCONTRACTOR_TYPE : Integer    @title: 'SUBCONTRACTOR_TYPE';
    key PHASE_ID           : String(36) @title: 'PHASE_ID';
    key BLOCK_ID           : String(36) @title: 'BLOCK_ID';
}

@cds.persistence.exists
entity ![DT_LINKED_REQUEST] : managed {
        ![ASSOCIATION_TYPE]   : String(36) @title        : 'ASSOCIATION_TYPE';
        ![CHILD_INSTANCE_ID]  : String(36) @title        : 'CHILD_INSTANCE_ID';
        ![CHILD_REQUEST_ID]   : String(36) @title        : 'CHILD_REQUEST_ID';
        ![CHILD_WORKFLOW_ID]  : String(36) @title        : 'CHILD_WORKFLOW_ID';
        ![DELETED]            : Boolean    @title        : 'DELETED';
        ![DELETED_AT]         : Timestamp  @cds.on.delete: $now   @title: 'DELETED_AT';
        ![DELETED_BY]         : User       @cds.on.delete: $user  @title: 'DELETED_BY';
    key ![LINK_ID]            : UUID       @title        : 'LINK_ID';
        ![PARENT_INSTANCE_ID] : String(36) @title        : 'PARENT_INSTANCE_ID';
        ![PARENT_REQUEST_ID]  : String(36) @title        : 'PARENT_REQUEST_ID';
        ![PARENT_WORKFLOW_ID] : String(36) @title        : 'PARENT_WORKFLOW_ID';
}

@cds.persistence.exists
entity ![JOINT_PROJECT] : managed {
    key ![JOINT_ID]          : UUID        @title        : 'JOINT_ID';
        ![COUNTRY_ID]        : String(3)   @title        : 'COUNTRY_ID';
        ![JOINT_CODE]        : String(16)  @title        : 'JOINT_CODE';
        ![EXTERNAL_ID]       : String(100) @title        : 'EXTERNAL_ID';
        ![MASTER_REQUEST_ID] : String(36)  @title        : 'MASTER_REQUEST_ID';
        ![DELETED]           : Boolean     @title        : 'DELETED';
        ![DELETED_AT]        : Timestamp   @cds.on.delete: $now   @title: 'DELETED_AT';
        ![DELETED_BY]        : User        @cds.on.delete: $user  @title: 'DELETED_BY';
}

@cds.persistence.exists
entity MANAGE_BUDGET {
        REQUEST_ID     : String(36)            @title: 'GUID Provision Request ID';
    key BUDGET_ID      : String(36)            @title: 'GUID Budget';
        ID_BLOCK_TYPE  : String(36)            @title: 'Process Flow block Id';
        IS_MANUAL      : Boolean default false @title: 'IS_MANUAL: Indicates that de register is manual or WO';
        WO_CODE        : String(12)            @title: 'WO_CODE: Work Order code only reported in not manual';
        DESCRIPTION    : String(100)           @title: 'DESCRIPTION: Description Only reported in manual entry, in WO entries it is extracted via WO_CODE';
        CATEGORY       : Integer               @title: 'CATEGORY: Category option';
        AMOUNT_REAL    : Double                @title: 'AMOUNT_REAL: Real Amount Only reported in manual entry, in WO entries it is extracted via WO_CODE';
        AMOUNT_BUDGET  : Double                @title: 'AMOUNT_BUDGET: Budget Amount Only reported in manual entry, in WO entries it is extracted via WO_CODE';
        CURRENCY       : String(3)             @title: 'CURRENCY: Currency Only reported in manual entry, in WO entries it is extracted via WO_CODE';
        EXTRA_COST     : Boolean               @title: 'EXTRA_COST: Indicate extra cost';
        PERCENTAGE     : Double                @title: 'PERCENTAGE: Work order percentage';
        VENDOR         : String(8)             @title: 'VENDOR: Vendor Id Only reported in manual entry, in WO entries it is extracted via WO_CODE';
        COMMENTS       : String(250)           @title: 'COMMENTS: Field for comment';
        CREATEDAT      : Timestamp             @title: 'CREATEDAT';
        CREATEDBY      : String(100)           @title: 'CREATEDBY';
        MODIFIEDAT     : Timestamp             @title: 'MODIFIEDAT';
        MODIFIEDBY     : String(100)           @title: 'MODIFIEDBY'; 
        DELETED_REASON : String(2000)          @title: 'DELETED_REASON';
        DELETED        : Boolean               @title: 'DELETED';
        DELETED_AT     : Timestamp             @title: 'DELETED_AT';
        DELETED_BY     : String(100)           @title: 'DELETED_BY';
}

@cds.persistence.exists
entity REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID {
    key REGISTER_ID                    : String(36)  @title: '{i18n>registerId}';
        DOCUMENT_ID                    : String(50)  @title: '{i18n>documentId}';
        REQUEST_ID                     : String(36)  @title: '{i18n>requestId}';
        APPROVER_TYPE                  : Integer     @title: '{i18n>approverType}';
        SUBCONTRACTOR                  : Integer     @title: '{i18n>subcontractor}';
        DEFAULT_RESPONSIBLE            : String(50)  @title: '{i18n>responsibleDefault}';
        SUBCO_REQ_VAL                  : Boolean     @title: '{i18n>subcontractorValidation}';
        CELLNEX_REQ_VAL                : Boolean     @title: '{i18n>cellnexValidation}';
        CUSTOMER__REQ_VAL              : Boolean     @title: '{i18n>customerValidation}';
        SITEOWNER_REQ_VAL              : Boolean     @title: '{i18n>siteOwnerValidation}';
        CREATEDAT                      : Timestamp   @title: '{i18n>createdAt}';
        CREATEDBY                      : String(100) @title: '{i18n>createdBy}';
        DELETED                        : Boolean     @title: '{i18n>deleted}';
        DELETED_AT                     : Timestamp   @title: '{i18n>deletedAt}';
        DELETED_BY                     : String(100) @title: '{i18n>deletebBy}';
        MODIFIEDAT                     : Timestamp   @title: '{i18n>modifiedAt}';
        MODIFIEDBY                     : String(100) @title: '{i18n>modifiedBy}';
        virtual cellnexResponsible              : String(50) @Core.Computed: false;
        virtual subcontractorResponsible        : String(50) @Core.Computed: false;    
        virtual agencyResponsible               : String(50) @Core.Computed: false;
        virtual customerResponsible             : String(50) @Core.Computed: false;    
        virtual cellnexResponsibleName          : String(200) @Core.Computed: false;
        virtual subcontractorResponsibleName    : String(200) @Core.Computed: false;    
        virtual agencyResponsibleName           : String(200) @Core.Computed: false;    
        virtual customerResponsibleName         : String(200) @Core.Computed: false;    
        virtual cellnexResponsibleFC            : UInt8 default 0;
        virtual subcontractorResponsibleFC      : UInt8 default 0;    
        virtual agencyResponsibleFC             : UInt8 default 0;    
        virtual customerResponsibleFC           : UInt8 default 0;    
        virtual documentIdFC                    : UInt8 default 3;
        virtual approverTypeName                : String(200);
        virtual approverTypeFC                  : UInt8 default 3;
        virtual subcoTypeName                   : String(200);
        virtual subcoTypeFC                     : UInt8 default 3;
        virtual responsibleDefaultName          : String(200);
        virtual responsibleDefaultFC            : UInt8 default 3;
        virtual documentNameVF                  : String(200); 
        virtual cellnexValidationFC             : UInt8 default 1;
        virtual subcontractorValidationFC       : UInt8 default 1;
        virtual customerValidationFC            : UInt8 default 1;
        virtual siteOwnerValidationFC           : UInt8 default 1;
}

@cds.persistence.exists
entity WF_CHAT {
    key REQUEST_ID : String(36)   @title: 'REQUEST_ID';
    key USER_ID    : String(100)  @title: 'USER_ID';
    key TIME       : Timestamp    @title: 'TIME';
        TEXT       : String(2500) @title: 'TEXT';
        READ       : Boolean      @title: 'READ';
}

@cds.persistence.exists
entity ![WF_ACTIONS_LOG] {
    key ![ACTIONS_LOG_ID] : Integer64            @title: 'ACTIONS_LOG_ID';
    key ![REQUEST_ID]     : String(36)           @title: 'REQUEST_ID';
        ![REQUEST_TYPE]   : Integer64 not null   @title: 'REQUEST_TYPE';
        ![DATE]           : Timestamp not null   @title: 'DATE';
        ![USER]           : String(100) not null @title: 'USER';
        ![ACTION]         : String(50) not null  @title: 'ACTION';
        ![PHASE_ID_PK]    : String(15)           @title: 'PHASE_ID_PK';
        ![BLOCK_ID_PK]    : String(15)           @title: 'BLOCK_ID_PK';
        ![FIELD_MOD]      : String(50)           @title: 'FIELD_MOD';
        ![OLD_VALUE]      : String(3000)         @title: 'OLD_VALUE';
        ![NEW_VALUE]      : String(3000)         @title: 'NEW_VALUE';
        ![PHASE_ID]       : String(36)           @title: 'PHASE_ID';
        ![BLOCK_ID]       : String(36)           @title: 'BLOCK_ID';
        ![DOCUMENT_ID]    : String(50)           @title: 'DOCUMENT_ID' ; 
        ![WORK_ID]        : String(36)           @title: 'WORK_ID' ; 
}

@cds.persistence.exists 
entity SEARCH_TYPES {
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
    key CODE: Integer  @title: 'CODE' ; 
}

@cds.persistence.exists 
entity SEARCH_TYPES_TEXTS {
    key CODE: Integer  @title: 'CODE' ; 
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

entity TASK_TYPES {
    key CODE: Integer  @title: 'CODE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

entity TASK_TYPES_TEXTS {
    key  CODE: Integer  @title: 'CODE' ; 
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity REQUEST_STATUS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity REQUEST_STATUS_TEXTS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity PHASE_STATUS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity PHASE_STATUS_TEXTS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity BLOCK_STATUS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity BLOCK_STATUS_TEXTS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity DOCUMENT_FLOW_STATUS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists 
entity DOCUMENT_FLOW_STATUS_TEXTS {
    key CODE: Integer default '0'  @title: 'CODE' ; 
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

@cds.persistence.exists
entity ![GET_ACTIVE_BUSINESS_SWITCH](country : String(2), companyCode : String(4), switch : String(40)) {
    ![SWITCH_CODE_PK]  : String(40);
    ![COUNTRY_PK]      : String(2);
    ![COMPANY_CODE_PK] : String(4);
    ![ACTIVE]          : Boolean;
}

entity ![CACHE_R3_ENTITIES] {
    key ![USER_ID]     : String(100) @cds.on.insert: $user;
    key ![ENTITY_TYPE] : String(50);
    key ![ENTITY_ID]   : String(50);
        ![ENTITY_NAME] : String(120);
        CREATED_AT     : Timestamp @cds.on.insert: $now;
}

entity REQUEST_IMPACTED_CUSTOMERS: cuid, managed {
    requestId:      UUID;
    customer:       String(10);
    deleted:        Boolean;
    deletedAt:      Timestamp;
    deletedBy:      User;
} 

@cds.persistence.exists
entity ![MASTER_MS_CONTRACT_RESTRICTIONS] : managed {
    key ![CONTRACT_RESTRICTIONS_ID]   : String(36) @title        : '{i18n>contractRestrictions}';
        ![CONTRACT_RESTRICTIONS_TXT]  : String(50) @title        : 'CONTRACT_RESTRICTIONS_TXT';
        ![DELETED]                    : Boolean    @title        : 'DELETED';
        ![DELETEDAT]                  : Timestamp  @cds.on.delete: $now   @title: 'DELETED_AT';
        ![DELETEDBY]                  : User       @cds.on.delete: $user  @title: 'DELETED_BY';
    key ![BLOCK_ID]                   : String(36) @title        : 'BLOCK_ID';
        virtual contractRestrictionIdUI : String(36) @Core.Computed: false @title        : '{i18n>contractRestrictions}';
        virtual contractRestrictionIdFC : UInt8 default 3;
}
