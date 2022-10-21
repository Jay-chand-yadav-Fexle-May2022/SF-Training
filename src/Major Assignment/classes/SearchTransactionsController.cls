/**
*  Description     :  Wrapper class and store user value and retieve records as user requirements
*                     
*  Created By      :  Jay Chand Yadav
*
*  Created Date    :  09/18/2022
*
*  Revision Logs   :  V1.0 - Created - jay Chand Yadav
**/
public with sharing class SearchTransactionsController {
    
    public Decimal amountFrom { get; set; }
    public Decimal amountUpto { get; set; }
    public Date dateFrom { get; set; }
    public Date dateUpto { get; set; }
    public String selectedStatus { get; set; }
    public String entryName { get; set; }
    public String accountNumber { get; set; }
    public List<Transaction_Entry__c> transactionData { get; set; }
        // Search the entries record as user requirement and use dynamic queries
        public void searchTransaction(){
        
        String query = 'SELECT Name, Status__c, Transaction_Date__c, Amount__c FROM Transaction_Entry__c ';
        List<String> tempList = new List<String>();
        Map<String, String> mapValues = new Map<String, String>{
                                    'amountFrom'=> String.valueOf(amountFrom),    // 1000
                                    'amountUpto'=> String.valueOf(amountUpto),    // 20000
                                    'dateFrom'=> String.valueOf(dateFrom),        // 2022/10/10
                                    'dateUpto'=> String.valueOf(dateUpto),        // 2022/10/26
                                    'selectedStatus'=> '\'' + String.valueOf(selectedStatus) + '\'',  // Completed
                                    'entryName'=> ' \''  + String.valueOf(entryName) + '\''           // auto-0039
                                    /*'accountNum'=> String.valueOf(accountNumber)  */      // acc-001
                                    };

            Map<String, String> mapOperators = new Map<String, String>{
                                    'amountFrom'=> 'Amount__c >= ', 
                                    'amountUpto'=> 'Amount__c <= ',
                                    'dateFrom'=> 'Transaction_Date__c >= ',
                                    'dateUpto'=> 'Transaction_Date__c <= ',
                                    'selectedStatus'=> 'Status__c = ',
                                    'entryName'=> 'Name = '
                                    /*'accountNum'=> 'Account_Number__c'*/
                                    };
                                        
        String filter = 'WHERE ';
        String quotes = '\'' + '\'';
        System.debug('=========> QUOTES ==== >  ' + quotes );
        for(String str: mapOperators.keySet()){
            //if(mapValues.get(str) != null && mapValues.get(str) != '0' && mapValues.get(str) != '\''+ '\''){
            if(mapValues.get(str) != null && mapValues.get(str) != '0' && !mapValues.get(str).trim().equals(quotes)){
                System.debug('-------------> map value -------->  ' + mapValues.get(str));
                tempList.add(mapOperators.get(str) + ' ' + String.valueOf(mapValues.get(str)));
            }
        }
        filter += String.join(tempList, ' AND ');
        query += filter;
        System.debug('Query: ' + query);
        transactionData = Database.query(query);       
    }
}