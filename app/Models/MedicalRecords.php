<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MedicalRecord extends Model
{
    protected $primaryKey = 'RecordID';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'RecordID', 'PetID', 'UserID', 'Diagnosis', 'Treatment', 'RecordDate'
    ];

    public function pet()
    {
        return $this->belongsTo(Pet::class, 'PetID', 'PetID');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'UserID', 'UserID');
    }
}
