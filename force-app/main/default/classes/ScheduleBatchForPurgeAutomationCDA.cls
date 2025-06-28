public class ScheduleBatchForPurgeAutomationCDA implements Schedulable {
    private String status;
    
    public ScheduleBatchForPurgeAutomationCDA() {
        // Default constructor
        // You can initialize any variables here if needed
    }
   
    public void execute(SchedulableContext context) {
        BatchForPurgeAutomationCDA batchtopurge = New BatchForPurgeAutomationCDA();
        Database.executeBatch(batchtopurge);    }
}