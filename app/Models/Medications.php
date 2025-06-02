<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medication extends Model
{
    protected $table = 'medications';
    protected $primaryKey = 'MedicationID';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'MedicationID',
        'Name',
        'UsageInstructions',
        'Quantity',
        'Unit',
    ];
}
