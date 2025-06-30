<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medications extends Model
{
    protected $table = 'medications';
    protected $primaryKey = 'MedicationID';
    protected $keyType = 'string'; // 👉 Thêm dòng này để Laravel không coi là int
    public $incrementing = false;  
    public $timestamps = false;

    protected $fillable = [
        'MedicationID',
        'Name',
        'UsageInstructions',
        'Quantity',
        'Unit',
        'ImageURL',
        'Price'
    ];
}
