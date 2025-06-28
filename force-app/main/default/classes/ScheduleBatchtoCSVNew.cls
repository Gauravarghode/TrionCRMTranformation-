public class ScheduleBatchtoCSVNew implements Schedulable {
    private String status;

    public ScheduleBatchtoCSVNew() {
        // Default constructor
        // You can initialize any variables here if needed
    }

    public ScheduleBatchtoCSVNew(String status) {
        // Constructor accepting a status parameter
        this.status = status;
    }

    public void execute(SchedulableContext context) {
BatchtoCSVNew batchtocsvBatch = New BatchtoCSVNew();
        Database.executeBatch(batchtocsvBatch);    }
}