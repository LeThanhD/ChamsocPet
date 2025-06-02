<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MedicalHistory extends Model
{
    protected $table = 'MedicalHistory';
    protected $primaryKey = 'HistoryID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'PetID',
        'VisitDate',
        'Symptoms',
        'Diagnosis',
        'Treatment',
        'Notes',
        'UserID'
    ];
}

