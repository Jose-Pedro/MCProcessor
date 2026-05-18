using {project} from './service';

annotate project.ChangesLog with @(
    UI: {
        LineItem: [
            { $Type : 'UI.DataField', Value :changeDate },
            { $Type : 'UI.DataField', Value :userId },
            { $Type : 'UI.DataField', Value :userAction },
            { $Type : 'UI.DataField', Value :phaseName },
            { $Type : 'UI.DataField', Value :blockName },
            { $Type : 'UI.DataField', Value :fieldName },
            { $Type : 'UI.DataField', Value :fieldDescription },
            { $Type : 'UI.DataField', Value :oldValue },
            { $Type : 'UI.DataField', Value :newValue },
            { $Type : 'UI.DataField', Value :documentName },
            { $Type : 'UI.DataField', Value :workType }
        ],
        SelectionFields: [
            changeDate,
            userId,
            phaseName,
            blockName,
            fieldName,
            fieldDescription,
            oldValue,
            newValue,
            documentName,
            workType,
        ]
    }
) {
    userAction @(
        Common: {
            Text           : userActionName,
            TextArrangement: #TextOnly
        }
    );
    oldValue @(
        Common: {
            Text           : oldValueDescription,
            TextArrangement: #TextFirst
        }
    );
    newValue @(
        Common: {
            Text           : newValueDescription,
            TextArrangement: #TextFirst
        }
    );
    workType @(Common: {
        Text           : workTypeName,
        TextArrangement: #TextFirst,
        ValueList: {
            CollectionPath: 'WorkTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: workType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
};