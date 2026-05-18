using {project} from './service';

annotate project.Sites with @(
    UI: {
        LineItem: [
            { $Type : 'UI.DataField', Value :siteId },
            { $Type : 'UI.DataField', Value :siteName },
            { $Type : 'UI.DataField', Value :legacyCode },
            { $Type : 'UI.DataField', Value :company },
            { $Type : 'UI.DataField', Value :cellnexZone }
        ],
        SelectionFields: [
            siteId,
            siteName,
            legacyCode,
            primaryLegacyCode,
            company,
        ],
        Identification  : [{Value: siteName}]
    },
    cds.odata.valuelist
) {
    siteId @(Common.Text: siteName );
    company @(
        Common: {
            Text: Companies.BUTXT,
            TextArrangement: #TextFirst
        }
    );
    cellnexZone @(
        Common: {
            Text: CellnexZones.description,
            TextArrangement: #TextFirst
        }
    );
    zone @(
        Common: {
            Text: Zones.description,
            TextArrangement: #TextFirst
        }
    );
    region @(
        Common: {
            Text: Regions.description,
            TextArrangement: #TextFirst
        }
    );
    infraOrigin @(
        Common: {
            Text: InfraOrigins.description,
            TextArrangement: #TextFirst
        }
    );
    infraOwnership @(
        Common: {
            Text: InfraOwnerships.description,
            TextArrangement: #TextFirst
        }
    );
    infraStatus @(
        Common: {
            Text: InfraStatus.description,
            TextArrangement: #TextFirst
        }
    );
    marketableId @(
        Common: {
            Text: Marketables.description,
            TextArrangement: #TextFirst
        }
    );
    abfZone @(
        Common: {
            Text: ABFZones.description,
            TextArrangement: #TextFirst
        }
    );
    managingCompany @(
        Common: {
            Text: ManagingCompanies.description,
            TextArrangement: #TextFirst
        }
    );
    cellnexProject @(
        Common: {
            Text: CellnexProjects.description,
            TextArrangement: #TextFirst
        }
    );
    exploited @(
        Common: {
            Text: Exploiteds.description,
            TextArrangement: #TextFirst
        }
    );
    productionZoneResponsible @(
        Common: {
            Text: productionZoneResponsibleName,
            TextArrangement: #TextFirst
        }
    );
    siteManagerZoneResponsible @(
        Common: {
            Text: siteManagerZoneResponsibleName,
            TextArrangement: #TextFirst
        }
    );
    productionRegionManager @(
        Common: {
            Text: productionRegionManagerName,
            TextArrangement: #TextFirst
        }
    );
    regionSiteManager @(
        Common: {
            Text: regionSiteManagerName,
            TextArrangement: #TextFirst
        }
    );
    productionManager @(
        Common: {
            Text: productionManagerName,
            TextArrangement: #TextFirst
        }
    );
    siteManager @(
        Common: {
            Text: siteManagerName,
            TextArrangement: #TextFirst
        }
    );
}

annotate project.RequestStatus with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @Common.Text: name;
};

annotate project.BlockStatus with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @Common.Text: name;
};

annotate project.TaskTypes with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @Common.Text: name;
};

annotate project.SearchTypes with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @Common.Text: name;
};

annotate project.RequestTypes with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: REQUEST_TYPE_DESC}]
) {
    REQUEST_TYPE @Common.Text: REQUEST_TYPE_DESC;
};

annotate project.InternalUsers with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: userName}]
) {
    userId      @(Common.Text: userName);
    requestId   @(UI.HiddenFilter: true);
    blockId     @(UI.HiddenFilter: true);
};

annotate project.ExternalUsers with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code      @(Common.Text: name);
    blockId     @(UI.HiddenFilter: true);
};

annotate project.PMOManagers with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: userName}]
) {
    userId @(
        Common: {
            Text: userName,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.Managers with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: userName}]
) {
    userId @(
        Common: {
            Text: userName,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.Requesters with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: userName}]
) {
    userId @(
        Common: {
            Text: userName,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.PreferredProviders with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}],
    UI.PresentationVariant: {
        SortOrder: [{
            Property: name,
            Descending: false
        }]
    }
) {
    code @(
        Common: {
            Text: name,
            TextArrangement: #TextFirst
        }
    );
};


annotate project.Customers with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: siteId },
        { $Type: 'UI.DataField', Value: customerId },
        { $Type: 'UI.DataField', Value: alias },
        { $Type: 'UI.DataField', Value: aliasServ },
        { $Type: 'UI.DataField', Value: aliasOther },
        { $Type: 'UI.DataField', Value: aliasClientArea },
        { $Type: 'UI.DataField', Value: aliasKey }
    ],
) {
    siteId @(
        Common: {
            Text: siteName,
            TextArrangement: #TextFirst
        }
    );
    customerId @(
        Common: {
            Text: customerName,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.ImpactedCustomers with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: siteId },
        { $Type: 'UI.DataField', Value: customerId },
        { $Type: 'UI.DataField', Value: alias },
        { $Type: 'UI.DataField', Value: aliasServ },
        { $Type: 'UI.DataField', Value: aliasOther },
        { $Type: 'UI.DataField', Value: aliasClientArea },
        { $Type: 'UI.DataField', Value: aliasKey },
        { $Type: 'UI.DataField', Value: impacted },
    ],
) {
    siteId @(
        Common: {
            Text: siteName,
            TextArrangement: #TextFirst
        }
    );
    customerId @(
        Common: {
            Text: customerName,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.Zones with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.CellnexZones with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: description}]
) {
    code @(
        Common: {
            Text: description,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.InfraOrigins with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.InfraOwnerships with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.InfraStatus with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.Marketables with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.ABFZones with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.Regions with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: description}]
) {
    code @(
        Common: {
            Text: description,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.ManagingCompanies with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.CellnexProjects with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.Exploiteds with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: desciption,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.ProjectTypes with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: name,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.AuxProjectTypes with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: name,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.ContractRestrictions {
    contractRestrictionId @(
        Common: {
            ValueListWithFixedValues: true,
            Text: ContractRestrictionsVH.name,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'ContractRestrictionVH',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: contractRestrictionId},
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            },
            FieldControl : contractRestrictionIdFC,
        }
    );
    contractRestrictionIdUI @(
        Common: {
            ValueListWithFixedValues: true,
            Text: ContractRestrictionsVH.name,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'ContractRestrictionVH',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: contractRestrictionIdUI},
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            },
            FieldControl : contractRestrictionIdFC
        }
    )
}

annotate project.InternalPhases with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}],
    UI.PresentationVariant: {
        SortOrder: [{
            Property: ORDER,
            Descending: false
        }]
    }
) {
    code @(
        Common: {
            Text: name,
            TextArrangement: #TextOnly
        }
    );
};

annotate project.InternalBlocks with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}],
    UI.PresentationVariant: {
        SortOrder: [
            {Property: phaseOrder, Descending: false},
            {Property: blockOrder, Descending: false}        
        ]
    }
) {
    code @(
        Common: {
            Text: name,
            TextArrangement: #TextOnly
        }
    );
};

annotate project.BooleanValues with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    code @(
        Common: {
            Text: name,
            TextArrangement: #TextOnly
        }
    );
};