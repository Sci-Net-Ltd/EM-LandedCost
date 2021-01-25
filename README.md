LandedCost, 07/10/2020
--Initial Commit
LandedCost, 15/10/2020
--General App, create package and sync with GitHub
LandedCost, 15/10/2020
--Eaglemoss Specific, added dependency on EM-Base APP
LandedCost, 21/10/2020
--Bug fix on PageID:66002-"Landed Cost Matrix"
--Bug fix on codeunit 66000 "Landed Cost Mgt."
--Update/recompile the extension as the version of the BaseApp has been restructured.
LandedCost, 30/12/2020
--Refactoring and fixing code in codeunit 66000 "Landed Cost Mgt."
--page 66002 "Landed Cost Matrix" changes to hide the Box and Brand columns
--Add new option to table 66002 "Landed Cost Matrix", on field "Matrix Line Type" for "Fixed Amount"
--Add support for the new option in codeunit codeunit 66000 "Landed Cost Mgt."
LandedCost, 25/01/2021
--Add check for the field "Matrix Line Type" to be <> empty in [EventSubscriber(ObjectType::Page, Page::"Item Charges", 'OnAfterActionEvent', 'Setup Landed Cost Matrix', false, false)] in codeunit 66000 "Landed Cost Mgt.".