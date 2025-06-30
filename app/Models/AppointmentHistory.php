<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class AppointmentHistory extends Model
{
    use HasFactory;

    protected $table = 'AppointmentHistory';
    protected $primaryKey = 'HistoryID';
    public $incrementing = false;
    protected $keyType = 'string';

    // ✅ Kích hoạt timestamps và gán cột cụ thể
    public $timestamps = false;
    const CREATED_AT = null;
    const UPDATED_AT = 'UpdatedAt';

    protected $fillable = [
        'HistoryID',
        'AppointmentID',
        'StatusBefore',
        'StatusAfter',
        'Note',
    ];

    // ✅ Quan hệ ngược đến cuộc hẹn
    public function appointment()
    {
        return $this->belongsTo(Appointment::class, 'AppointmentID', 'AppointmentID');
    }
}
