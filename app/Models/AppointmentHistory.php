<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppointmentHistory extends Model
{
    protected $table = 'AppointmentHistory';
    protected $primaryKey = 'HistoryID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'AppointmentID', 'UpdatedAt', 'StatusBefore', 'StatusAfter', 'Note'
    ];
}
