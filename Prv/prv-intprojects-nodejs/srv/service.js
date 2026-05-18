const { SearchCode } = require('./code/searches')
const { RequestsCode } = require('./code/requests')
const { GenericCode } = require('./code/generic')
const { UserCode } = require('./code/users')
const { PhasesCode }  = require('./code/phases')
const { BlocksCode } = require('./code/blocks')
const { WorksCode } = require('./code/works')
const { ChecklistItemsCode } = require('./code/checklists')
const { DocumentsCode } = require('./code/documents')
const { CustomersCode } = require('./code/customers')
const { UnboundActionsCode } = require('./code/unboundactions')
const { LogCode } = require('./code/log')
const { ChatsCode } = require('./code/chats')
const { SitesCode } = require('./code/sites')
const { ValueHelpsCode } = require('./code/valuehelps')
const { DPBCode } = require('./code/documentsperblock')
const { ServicesHandler } = require('./external/servicesHandler')
const { DataServicesHandler } = require('./external/dataServicesHandler')
const { ServicesECCHandler } = require('./external/servicesECCHandler')
const { LinkedRequestsCode } = require('./code/linkedRequests')
const { DPRCode } = require('./code/documentsPerRequest')
const { DVNCode } = require('./code/documentViewerNodes')
const { ContractResctrictionsCode } = require('./code/contractRestrictions')
class ServiceLogic extends cds.ApplicationService {
    
    init() {
        this.oSearchHandler = new SearchCode()
        this.oRequestsHandler = new RequestsCode()
        this.oGenericHandler = new GenericCode()
        this.oPhasesHandler = new PhasesCode()
        this.oBlocksHandler = new BlocksCode()
        this.oWorksHandler = new WorksCode()
        this.oChecklistItemsHandler = new ChecklistItemsCode()
        this.oDPBHandler = new DPBCode()
        this.oDocumentsHandler = new DocumentsCode()
        this.oCustomersHandler = new CustomersCode()
        this.oUnboundActionsHandler = new UnboundActionsCode()
        this.oLogHandler = new LogCode()
        this.oSitesHandler = new SitesCode()
        this.oChatsHandler = new ChatsCode()
        this.oValueHelpsHandler = new ValueHelpsCode()
        this.oServicesHandler = new ServicesHandler()
        this.oServicesHandler.initialize()
        this.oDataServicesHandler = new DataServicesHandler()
        this.oDataServicesHandler.initialize()
        this.oServicesECCHandler = new ServicesECCHandler()
        this.oServicesECCHandler.initialize()
        this.oLinkedRequestsHandler = new LinkedRequestsCode()
        this.oDPRHandler = new DPRCode()
        this.oDVNHandler = new DVNCode()
        this.oContractResctrictionsHandler = new ContractResctrictionsCode()
        
        const { 
            SearchByRequests, 
            SearchByTasks, 
            Requests, 
            RequestProvision, 
            Phases, 
            Blocks, 
            BlockProvision,
            DocumentsPerBlocks,
            InstancesPerDocuments,
            DocumentFlowDocumentId,
            Documents,
            SupportDocuments,
            LocalDocuments, 
            ChangesLog, 
            Sites, 
            InternalUsers, 
            ExternalUsers,
            Works,
            WorkDocuments,
            ChecklistItems,
            ImpactedCustomers,
            AfterCreateExits,
            AfterReadExits,
            AfterUpdateExits,
            AuxProjectTypes,
            ProjectObjectivesCountry,
            ServicesECC,
            Services,
            ContractRestrictions
        } = this.entities

        //Generic Handlers
        this.before('*', '*',  async oRequest => { await UserCode.currentUserDetails(oRequest) })
        this.before('READ', ['Managers', 'PMOManagers', 'Requesters'], async (oRequest) => { await this.oGenericHandler.addFilterByCountry(oRequest) })

        //Search Handlers
        this.on ('READ', [SearchByRequests, SearchByTasks], async oRequest => { await this.oSearchHandler.onReadSearch(oRequest) })

        //Localized ProjectTypes 
        this.before ('READ', AuxProjectTypes, async oRequest => { await this.oValueHelpsHandler.beforeReadProjectTypes(oRequest) })
        this.before ('READ', ProjectObjectivesCountry, async oRequest => { await this.oValueHelpsHandler.beforeReadProjectObjectivesCountry(oRequest) } )

        //Request Handlers
        this.before ('CREATE', Requests, async oRequest => { await this.oRequestsHandler.beforeCreateRequest(oRequest) })
        this.on ('CREATE', Requests, async oRequest => { await this.oRequestsHandler.onCreateRequest(oRequest) })

        this.before ('READ', Requests, async oRequest => { await this.oRequestsHandler.beforeReadRequest(oRequest) })
        this.after ('READ', Requests, async (oResult, oRequest) => { await this.oRequestsHandler.afterReadRequest(oResult, oRequest) })

        this.before ('UPDATE', Requests, async oRequest => { await this.oRequestsHandler.beforeUpdateRequest(oRequest) })
        this.after ('UPDATE', Requests, async (oResult, oRequest) => { await this.oRequestsHandler.afterUpdateRequest(oResult, oRequest) })

        this.on('reopen', Requests, async (oRequest, next) => { await this.oRequestsHandler.onReopenRequest(oRequest, next)})
        this.on('close', Requests, async (oRequest, next) => { await this.oRequestsHandler.onCloseRequest(oRequest, next)})
        this.on('cancel', Requests, async (oRequest, next) => { await this.oRequestsHandler.onCancelRequest(oRequest, next)})
        this.on('setOnHold', Requests, async (oRequest, next) => { await this.oRequestsHandler.onRequestSetOnHold(oRequest, next)})
        this.on('takeOwnership', Requests, async (oRequest, next) => { await this.oRequestsHandler.onTakeOwnershipRequest(oRequest, next)})

        this.on('confirmInventoryCheck', Requests, async (oRequest, next) => { await this.oRequestsHandler.onConfirmInventoryCheck(oRequest, next, this.oDataServicesHandler)})
        this.on('confirmInventory', Requests, async (oRequest, next) => { await this.oRequestsHandler.onConfirmInventory(oRequest, next)})
        this.on('confirmService', Requests, async (oRequest, next) => { await this.oRequestsHandler.onConfirmServices(oRequest, next)})
        this.on('confirmDocuments', Requests, async (oRequest, next) => { await this.oRequestsHandler.onConfirmDocuments(oRequest, next)})

        this.on('READ', 'DocumentFlowResponsiblesDefaultValid', async (oRequest) => { await this.oDPBHandler.onReadDocumentFlowResponsiblesDefaultValid(oRequest)})
        this.on('READ', 'DocumentFlowDefaultValidDocumentId', async (oRequest) => { await this.oDPBHandler.onReadDocumentFlowDefaultValidDocumentId(oRequest)})
        this.on('onCancelDefaultValidators', Requests, async (oRequest, next) => { await this.oDPBHandler.onCancelDefaultValidators(oRequest, next)})
        this.on('addRequestDocumentsPerBlockDefaultValid', Requests, async (oRequest) => { await this.oDPBHandler.onAddRequestDocumentsPerBlockDefaultValid(oRequest)})
        this.on('deleteAllDocumentsPerBlockDefaultValid', Requests, async (oRequest) => { await this.oDPBHandler.deleteAllDocumentsPerBlockDefaultValid(oRequest)})
        this.on('onUpdateToDefaultDocumentsPerBlockDefaultValid', Requests, async (oRequest) => { await this.oDPBHandler.onUpdateToDefaultDocumentsPerBlockDefaultValid(oRequest)})
        
        this.on('delete', 'RequestDocumentsPerBlockDefaultValid', async (oRequest, next) => { await this.oDPBHandler.onDeleteRequestDocumentsPerBlockDefaultValid(oRequest); next() })    
        this.before('UPDATE', 'RequestDocumentsPerBlockDefaultValid', async (oRequest) => { await this.oDPBHandler.beforeUpdateDocumentsPerBlocksDefaultValid(oRequest) })
        this.after('READ', 'RequestDocumentsPerBlockDefaultValid', async (oResult, oRequest) => { await this.oDPBHandler.afterReadRequestDocumentsPerBlockDefaultValid(oResult, oRequest) })

        //Request provision handlers
        this.after('READ', RequestProvision, async (oResult, oRequest) => { await this.oRequestsHandler.afterReadRequestProvision(oResult, oRequest) })
        this.before('UPDATE', RequestProvision, async oRequest => { await this.oRequestsHandler.beforeUpdateRequestProvision(oRequest) })
        this.after('UPDATE', RequestProvision, async (oResult, oRequest) => { await this.oRequestsHandler.afterUpdateRequestProvision(oResult, oRequest) })

        //Phase Handlers
        this.before ('READ', Phases, async oRequest => { await this.oPhasesHandler.beforeReadPhase(oRequest) })
        this.after ('READ', Phases, async (oPhases, oRequest) => { await this.oPhasesHandler.afterReadPhase(oPhases, oRequest) })
        
        this.before('close', Phases, async (oRequest) => { await this.oPhasesHandler.beforePhaseClose(oRequest) })
        this.on('close', Phases, async (oRequest, next) => { await this.oPhasesHandler.onPhaseClose(oRequest); return next() })

        //Block Handlers
        this.before('CREATE', Blocks, async (oRequest) => { await this.oBlocksHandler.beforeCloseBlock(oRequest)})
        this.after ('READ', Blocks, async (oBlocks, oRequest) => { await this.oBlocksHandler.afterReadBlock(oBlocks, oRequest) })
        this.before ('UPDATE', Blocks, async oRequest => { await this.oBlocksHandler.beforeUpdateBlock(oRequest) })

        this.before('close', Blocks, async (oRequest) => { await this.oBlocksHandler.beforeCloseBlock(oRequest) })
        this.on('close', Blocks, async (oRequest) => { await this.oBlocksHandler.onCloseBlock(oRequest) })
        this.on('reOpen', Blocks, async (oRequest) => { await this.oBlocksHandler.onReopenBlock(oRequest) })
        this.on('addDocumentPerBlock', Blocks, async (oRequest) => { await this.oBlocksHandler.onAddDocumentPerBlock(oRequest) }) 

        //BlockProvision Handler
        this.after('READ', BlockProvision, async (aResult, oRequest) => { await this.oBlocksHandler.afterReadBlockProvision(aResult, oRequest) })
        this.before('UPDATE', BlockProvision, async (oRequest) => { await this.oBlocksHandler.beforeUpdateBlockProvision(oRequest) })      

        //Works Handlers
        this.before('CREATE', Works, async (oRequest) => { await this.oWorksHandler.beforeCreateWork(oRequest) })
        this.after('READ', Works, async (aResult, oRequest) => { await this.oWorksHandler.afterReadWork(aResult, oRequest) })
        this.before('UPDATE', Works, async (aResult, oRequest) => { await this.oWorksHandler.beforeUpdateWork(aResult, oRequest) })

        this.on('complete', Works, async (oRequest) => { await this.oWorksHandler.onCompleteWork(oRequest) })
        this.on('cancel', Works, async (oRequest) => { await this.oWorksHandler.onCancelWork(oRequest) })
        this.on('reopen', Works, async (oRequest) => { await this.oWorksHandler.onReopenWork(oRequest) })
        this.on('addDocumentPerBlock', Works, async (oRequest) => { await this.oWorksHandler.onAddDocumentPerBlock(oRequest) })

        this.before('READ', WorkDocuments, async (oRequest) => { await this.oWorksHandler.beforeReadWorkDocuments(oRequest) })

        //Checklist Handlers
        this.before('CREATE', ChecklistItems, async (oRequest) => { await this.oChecklistItemsHandler.beforeCreateChecklistItems(oRequest) })
        this.after('READ', ChecklistItems, async (aResult, oRequest) => { await this.oChecklistItemsHandler.afterReadChecklistItems(aResult, oRequest) })
        this.before('UPDATE', ChecklistItems, async (oRequest) => { await this.oChecklistItemsHandler.beforeUpdateChecklistItems(oRequest) })
        this.after('UPDATE', ChecklistItems, async (oData, oRequest) => { await this.oChecklistItemsHandler.afterUpdateChecklistItems(oData, oRequest) })
        this.on('DELETE', ChecklistItems, async (oRequest) => { await this.oChecklistItemsHandler.onDeleteChecklistItems(oRequest) })

        this.on('READ', AfterCreateExits, async (oRequest) => { this.oChecklistItemsHandler.onReadAfterCreateExits(oRequest) } )
        this.on('READ', AfterReadExits, async (oRequest) => { this.oChecklistItemsHandler.onReadAfterReadExits(oRequest) } )
        this.on('READ', AfterUpdateExits, async (oRequest) => { this.oChecklistItemsHandler.onReadAfterUpdateExits(oRequest) } )

        //ContractRestrictions Handler
        this.before('CREATE', ContractRestrictions, async (oRequest) => { await this.oContractResctrictionsHandler.beforeCreateContractRestrictions(oRequest) } )
        this.after('READ', ContractRestrictions, async (oResult, oRequest) => { await this.oContractResctrictionsHandler.afterReadContractRestrictions(oResult, oRequest) } )
        //NOSONAR this.on('DELETE', ContractRestrictions, async (oRequest) => { await this.oContractResctrictionsHandler.onDeleteContractRestrictions(oRequest) } )

        //Documents per block handler
        this.after('READ', DocumentsPerBlocks, async (aResult, oRequest) => { await this.oDPBHandler.afterReadDocumentsPerBlock(aResult, oRequest) })
        this.before('UPDATE', DocumentsPerBlocks, async (oRequest) => { await this.oDPBHandler.beforeUpdateDocumentsPerBlocks(oRequest) })
        this.after('READ', InstancesPerDocuments, async (oResult, oRequest) => { await this.oDPBHandler.afterReadInstancesPerDocument(oResult, oRequest) })    
        this.before('UPDATE', InstancesPerDocuments, async (oRequest) => { await this.oDPBHandler.beforeUpdateInstancesPerDocument(oRequest) })  
        this.on('READ', DocumentFlowDocumentId, async (oRequest) => { await this.oDPBHandler.onReadDocumentFlowDocumentId(oRequest) })

        this.on('docFlowFirstSave', DocumentsPerBlocks, async (oRequest) => { await this.oDPBHandler.onDocFlowFirstSave(oRequest) })
        this.before('nextStep', DocumentsPerBlocks, async (oRequest) => { await this.oDPBHandler.beforeNextStep(oRequest) })
        this.on('nextStep', DocumentsPerBlocks, async (oRequest) => { await this.oDPBHandler.onNextStep(oRequest) })
        this.on('cancel', DocumentsPerBlocks, async (oRequest) => { await this.oDPBHandler.onCancelDocument(oRequest) })
        this.on('before', InstancesPerDocuments, async (oRequest) => { await this.oDPBHandler.beforeCancelIPDocument(oRequest) })
        this.on('cancel', InstancesPerDocuments, async (oRequest) => { await this.oDPBHandler.onCancelIPDocument(oRequest) })
    
        //Documents Handler
        this.on('CREATE', LocalDocuments, async (oRequest) => { await this.oDocumentsHandler.onCreateDocument(oRequest) })
        this.on('UPDATE', LocalDocuments, async (oRequest) => { await this.oDocumentsHandler.onUpdateDocument(oRequest) })
        this.on('DELETE', Documents, async (oRequest) => { await this.oDocumentsHandler.onDeleteDocuments(oRequest) })
        this.after("READ", Documents, async (aResults, oRequest, oEntities) => { await  this.oDocumentsHandler.afterReadDocuments(aResults, oRequest, oEntities) })
        this.on("READ", SupportDocuments, async (oRequest) => { await  this.oDocumentsHandler.onReadSupportDocuments(oRequest) })
    
        //Customer Handler
        this.on('READ', ImpactedCustomers, async (oRequest)  => { await this.oCustomersHandler.onReadImpactedCustomers(oRequest) })
        this.on('UPDATE', ImpactedCustomers, async (oRequest)  => { await this.oCustomersHandler.onUpdateImpactedCustomers(oRequest) })

        //Unbound actions Handler
        this.on('getRequestAllowedActions', async (oRequest) => { await this.oUnboundActionsHandler.getRequestAllowedActions(oRequest) })
        this.on('getBlocksAllowedActions', async (oRequest) => { await this.oUnboundActionsHandler.getBlocksAllowedActions(oRequest) })
        this.on('getDefaultCreationFields', async (oRequest) => { await this.oUnboundActionsHandler.getDefaultCreationFields(oRequest) })
        this.on('refreshR3EntitiesCache', async (oRequest) => { await this.oUnboundActionsHandler.refreshR3EntitiesCache(oRequest) })
        this.on('newRequestDocument', async (oRequest) => { await this.oDPBHandler.onAddDocumentsPerRequest(oRequest) })
        this.on('getPhasesStatus', async (oRequest) => { await this.oUnboundActionsHandler.getPhasesStatus(oRequest) }) 
        
        //Responsibles value help entities
        this.on('READ', InternalUsers, async oRequest => { await this.oValueHelpsHandler.onReadInternalUsers(oRequest) })
        this.on('READ', ExternalUsers, async oRequest => { await this.oValueHelpsHandler.onReadExternalUsers(oRequest) })

        //Log entities Handlers
        this.after('READ', ChangesLog, async (aResults, oRequest) => { await this.oLogHandler.afterReadChangesLog(aResults, oRequest) })

        //Sites handler
        this.before('READ', Sites, async oRequest => { await this.oSitesHandler.beforeReadSites(oRequest) })
        this.after('READ', Sites, async (oResult, oRequest) => { await this.oSitesHandler.afterReadSites(oResult, oRequest) })

        //Chat Handlers
        this.before('INSERT', 'Chats', async(oRequest) => {  this.oChatsHandler.onBeforeInsertChat(oRequest)}) 

        //Chat Services
        this.on('READ', Services, async (oRequest) => {  await this.oServicesHandler.onReadServices(oRequest) })
        this.on('READ', ServicesECC, async (oRequest) => {  await this.oServicesECCHandler.onReadServicesECC(oRequest) })
        
        //Linked Request
        this.on('linkRequestsDetailed', async (oRequest) => { await this.oLinkedRequestsHandler.onCreate(oRequest) })
        // might not needed it
        this.before('linkRequestsDetailed', 'DtLinkedRequest', async (req) => { await this.oLinkedRequestsHandler.onBeforeCreate(req) })
        this.after('linkRequestsDetailed', 'DtLinkedRequest', async (req) => { await this.oLinkedRequestsHandler.onAfterCreate(req) })
        this.before('UPDATE', 'DtLinkedRequest', async (oRequest) => { await this.oLinkedRequestsHandler.onBeforeDelete(oRequest) })
        this.before('READ', 'DtLinkedRequest', async (req) => { await this.oLinkedRequestsHandler.onBeforeRead(req) })
        this.before('READ', 'DtLinkedRequestPossibleChildrenRequestList', async (req) => { await this.oLinkedRequestsHandler.dtLinkedRequestPossibleChildrenRequestListBeforeRead(req) })

        //**************** Block Responsibles Handlers       *************/
        this.before('UPDATE', 'BlocksResponsibles', async (oRequest) => { await this.oBlocksHandler.beforeUpdateBlocksResponsibles(oRequest)})
        this.on('READ', 'BlocksResponsibles', async (oRequest) => { await this.oBlocksHandler.onReadBlocksResponsibles(oRequest)})
        this.after('READ', 'BlocksResponsibles', async (aResult,oRequest) => { await this.oBlocksHandler.afterReadBlocksResponsibles(aResult,oRequest)})
        this.on('UPDATE', 'BlocksResponsibles', async (oRequest) => {  await this.oBlocksHandler.onUpdateBlocksResponsibles(oRequest)})

         /************************* Documents Per Request Handler ***************************/
        this.after('READ', 'DocumentsPerRequest', async (aResult, oRequest) => { await this.oDPBHandler.afterReadDocumentsPerBlock(aResult, oRequest) })
        this.before('UPDATE', 'DocumentsPerRequest', async (oRequest) => { await this.oDPBHandler.beforeUpdateDocumentsPerBlocks(oRequest) })
        this.on('UPDATE', 'DocumentsPerRequest', async (oRequest) => { return await this.oDPRHandler.onUpdateDocumentsPerRequests(oRequest) })        
        this.on('READ', 'DocumentFlowResponsibles', async (oRequest) => { await this.oDPRHandler.onReadDocumentFlowResponsibles(oRequest) })

        //**************** Document Viewer                      ***f**********/
        this.on('READ', 'DocumentViewerNodes', async (oRequest) => { await this.oDVNHandler.onReadDocumentViewerNodes(oRequest) })

        return super.init()
    }
}

module.exports = ServiceLogic