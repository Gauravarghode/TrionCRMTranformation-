public class SchdeuleBatchToEmailMessageRecordPurge implements Schedulable {
    private String status;


    public SchdeuleBatchToEmailMessageRecordPurge(String status) {
        // Constructor accepting a status parameter
        this.status = status;
    }

    public void execute(SchedulableContext context) {
BatchForPurgeAutomationCDA batchtocsvBatch = New BatchForPurgeAutomationCDA();
        Database.executeBatch(batchtocsvBatch);    }
}