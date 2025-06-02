<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        DB::unprepared('
            CREATE TRIGGER trg_UserLogs_Insert BEFORE INSERT ON user_logs
            FOR EACH ROW
            BEGIN
                DECLARE log_count INT;
                SET log_count = (SELECT COUNT(*) FROM user_logs);
                SET NEW.LogID = CONCAT("USRLOG", LPAD(log_count + 1, 4, "0"));
                IF NEW.ActionTime IS NULL THEN
                    SET NEW.ActionTime = NOW();
                END IF;
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_Services_Insert BEFORE INSERT ON services
            FOR EACH ROW
            BEGIN
                DECLARE serv_count INT;
                SET serv_count = (SELECT COUNT(*) FROM services);
                SET NEW.ServiceID = CONCAT("SERV", LPAD(serv_count + 1, 4, "0"));
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_ServiceCategories_Insert BEFORE INSERT ON service_categories
            FOR EACH ROW
            BEGIN
                DECLARE cat_count INT;
                SET cat_count = (SELECT COUNT(*) FROM service_categories);
                SET NEW.CategoryID = CONCAT("CAT", LPAD(cat_count + 1, 4, "0"));
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_Medications_Insert BEFORE INSERT ON medications
            FOR EACH ROW
            BEGIN
                DECLARE med_count INT;
                SET med_count = (SELECT COUNT(*) FROM medications);
                SET NEW.MedicationID = CONCAT("MED", LPAD(med_count + 1, 4, "0"));
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_Prescriptions_Insert BEFORE INSERT ON prescriptions
            FOR EACH ROW
            BEGIN
                DECLARE pre_count INT;
                SET pre_count = (SELECT COUNT(*) FROM prescriptions);
                SET NEW.PrescriptionID = CONCAT("PRE", LPAD(pre_count + 1, 4, "0"));
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_AppointmentHistory_Insert BEFORE INSERT ON appointment_history
            FOR EACH ROW
            BEGIN
                DECLARE ahis_count INT;
                SET ahis_count = (SELECT COUNT(*) FROM appointment_history);
                SET NEW.HistoryID = CONCAT("AHIS", LPAD(ahis_count + 1, 4, "0"));
                IF NEW.UpdatedAt IS NULL THEN
                    SET NEW.UpdatedAt = NOW();
                END IF;
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_Invoices_Insert BEFORE INSERT ON invoices
            FOR EACH ROW
            BEGIN
                DECLARE inv_count INT;
                SET inv_count = (SELECT COUNT(*) FROM invoices);
                SET NEW.InvoiceID = CONCAT("INV", LPAD(inv_count + 1, 4, "0"));
                IF NEW.CreatedAt IS NULL THEN
                    SET NEW.CreatedAt = NOW();
                END IF;
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_InvoiceDetails_Insert BEFORE INSERT ON invoice_details
            FOR EACH ROW
            BEGIN
                DECLARE idet_count INT;
                SET idet_count = (SELECT COUNT(*) FROM invoice_details);
                SET NEW.DetailID = CONCAT("IDET", LPAD(idet_count + 1, 4, "0"));
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_PetNotes_Insert BEFORE INSERT ON pet_notes
            FOR EACH ROW
            BEGIN
                DECLARE note_count INT;
                SET note_count = (SELECT COUNT(*) FROM pet_notes);
                SET NEW.NoteID = CONCAT("PNOTE", LPAD(note_count + 1, 4, "0"));
                IF NEW.CreatedAt IS NULL THEN
                    SET NEW.CreatedAt = NOW();
                END IF;
            END
        ');
    }

    public function down()
    {
        DB::unprepared('DROP TRIGGER IF EXISTS trg_UserLogs_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_Services_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_ServiceCategories_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_Medications_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_Prescriptions_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_AppointmentHistory_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_Invoices_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_InvoiceDetails_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_PetNotes_Insert');
    }
};
