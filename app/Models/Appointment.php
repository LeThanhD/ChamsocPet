<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Users;
use App\Models\Service;
use App\Models\Pet;
use App\Models\AppointmentHistory;

class Appointment extends Model
{
    use HasFactory;

    protected $table = 'appointments';
    protected $primaryKey = 'AppointmentID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'AppointmentID',
        'PetID',
        'UserID',
        'ServiceID',
        'AppointmentDate',
        'AppointmentTime',
        'Reason',
        'Status',
        'StaffID',
    ];

    protected $casts = [
    'AppointmentDate' => 'date',
    'AppointmentTime' => 'datetime:H:i:s',
];


    // ✅ Quan hệ đến chủ thú cưng
    public function user()
    {
        return $this->belongsTo(Users::class, 'UserID', 'UserID')
                    ->select(['UserID', 'FullName']);
    }

    // ✅ Quan hệ đến thú cưng
    public function pet()
    {
        return $this->belongsTo(Pet::class, 'PetID', 'PetID')
                    ->select(['PetID', 'Name']);
    }

    // ✅ Quan hệ đến dịch vụ
    public function service()
    {
        return $this->belongsTo(Service::class, 'ServiceID', 'ServiceID');
    }

    // ✅ Quan hệ đến lịch sử cuộc hẹn
    public function histories()
    {
        return $this->hasMany(AppointmentHistory::class, 'AppointmentID', 'AppointmentID');
    }

    // ✅ Quan hệ đến nhân viên phụ trách
    public function staff()
    {
        return $this->belongsTo(Users::class, 'StaffID', 'UserID')
                    ->select(['UserID', 'FullName']);
    }

    // ✅ Scope để lọc các cuộc hẹn đang chờ xử lý
    public function scopePending($query)
    {
        return $query->where('Status', 'pending');
    }
}
