<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up()
    {
        DB::unprepared('
            CREATE TRIGGER trg_Users_Insert BEFORE INSERT ON users
            FOR EACH ROW
            BEGIN
                DECLARE prefix VARCHAR(10);
                DECLARE next_id INT DEFAULT 1;
                DECLARE new_id VARCHAR(50);

                IF NEW.Role = "staff" THEN
                    SET prefix = "STAFF";
                ELSE
                    SET prefix = "OWNER";
                END IF;

                WHILE TRUE DO
                    SET new_id = CONCAT(prefix, LPAD(next_id, 4, "0"));
                    IF (SELECT COUNT(*) FROM users WHERE UserID = new_id) = 0 THEN
                        SET NEW.UserID = new_id;
                        LEAVE;
                    END IF;
                    SET next_id = next_id + 1;
                END WHILE;

                IF NEW.CreatedAt IS NULL THEN
                    SET NEW.CreatedAt = NOW();
                END IF;
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_Pets_Insert BEFORE INSERT ON pets
            FOR EACH ROW
            BEGIN
                DECLARE owner_name VARCHAR(100);
                DECLARE pet_name_clean VARCHAR(100);
                DECLARE pet_id_generated VARCHAR(100);

                SELECT FullName INTO owner_name FROM users WHERE UserID = NEW.UserID;
                SET owner_name = REPLACE(owner_name, " ", "");
                SET pet_name_clean = REPLACE(NEW.Name, " ", "");
                SET pet_id_generated = UPPER(CONCAT(owner_name, pet_name_clean, DATE_FORMAT(NEW.BirthDate, "%d")));

                SET NEW.PetID = pet_id_generated;
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_MedicalRecords_Insert BEFORE INSERT ON medical_records
            FOR EACH ROW
            BEGIN
                DECLARE date_str VARCHAR(8);
                SET date_str = DATE_FORMAT(NEW.RecordDate, "%Y%m%d");
                SET NEW.RecordID = CONCAT(NEW.PetID, "_", NEW.UserID, "_", date_str);
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_MedicalHistory_Insert BEFORE INSERT ON medical_history
            FOR EACH ROW
            BEGIN
                SET NEW.HistoryID = CONCAT("HIS_", NEW.PetID, DATE_FORMAT(NEW.VisitDate, "%d%m"));
            END
        ');

        DB::unprepared('
            CREATE TRIGGER trg_Appointments_Insert BEFORE INSERT ON appointments
            FOR EACH ROW
            BEGIN
                DECLARE date_str VARCHAR(10);
                DECLARE time_str VARCHAR(10);
                SET date_str = DATE_FORMAT(NEW.AppointmentDate, "%Y%m%d");
                SET time_str = DATE_FORMAT(NEW.AppointmentTime, "%H%i%s");
                SET NEW.AppointmentID = CONCAT(NEW.PetID, "_", NEW.UserID, "_", date_str, "_", time_str);
            END
        ');
    }

    public function down()
    {
        DB::unprepared('DROP TRIGGER IF EXISTS trg_Users_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_Pets_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_MedicalRecords_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_MedicalHistory_Insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_Appointments_Insert');
    }
};
