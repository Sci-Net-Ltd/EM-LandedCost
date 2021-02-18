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
LandedCost, 26/01/2021
--Change on page 66005 "Container Item Charges", property UsageCategory to None. Hide it from global search.
--Add new page extension 66004 ContainerCardExt extends "Container Card" and new action to open "Container Item Charges".
LandedCost, 15/01/2021 - 17/01/2021
--Several changes and bug fixing with Tim. No time to document.
--Add function ConvertCurrency() to convert between currencies in codeunit 66000 "Landed Cost Mgt."
--Add new field for Currency Code in table 66002 "Landed Cost Matrix".
--Add new field in page 66002 "Landed Cost Matrix" and enabled only if not Value Type = Percentage.
LandedCost, 18/01/2021
--Fix to show the breakdown of the landed cost in purchase order lines, in the correct currency/conversion.