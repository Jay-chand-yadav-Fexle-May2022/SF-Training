/**
*  Description     :  Trigger work when user enter new record
*
*  Created By      :  Jay Chand Yadav
*
*  Created Date    :  07/21/2022
*
*  Revision Logs   :    V1.0 - Created - jay Chand Yadav
**/
trigger Trigger_Account_1 on Account (before insert) {

    if(Trigger.isInsert) {
    	if(Trigger.isBefore) 
        {
            AccountTriggerHandler.updateTheAccountsNumber(Trigger.New);
        }
        
        if(Trigger.isAfter) {
        	AccountTriggerHandler.sendEmail(Trigger.New);
    	}
    }
}