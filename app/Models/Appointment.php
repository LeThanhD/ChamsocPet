<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    protected $table = 'Appointments';
    protected $primaryKey = 'AppointmentID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'PetID', 'UserID', 'AppointmentDate', 'AppointmentTime', 'Reason', 'Status'
    ];
}
