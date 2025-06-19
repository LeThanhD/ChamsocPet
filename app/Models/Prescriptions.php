<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Prescriptions extends Model
{
    protected $table = 'prescriptions';
    protected $primaryKey = 'PrescriptionID';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'PrescriptionID',
        'RecordID',
        'MedicationID',
        'Dosage',
        'Frequency',
        'Duration',
    ];

    public $timestamps = false;

    public function record()
    {
        return $this->belongsTo(MedicalRecord::class, 'RecordID', 'RecordID');
    }

    public function medication()
    {
        return $this->belongsTo(Medication::class, 'MedicationID', 'MedicationID');
    }
}
