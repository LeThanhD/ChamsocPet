<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Users;
use App\Models\Service;
use App\Models\Pet;

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
    ];

    // ✅ Quan hệ đến Users trả về FullName
    public function user()
    {
        return $this->belongsTo(Users::class, 'UserID', 'UserID')
                    ->select(['UserID', 'FullName']);
    }

    // ✅ Quan hệ đến Pets trả về Name
    public function pet()
    {
        return $this->belongsTo(Pet::class, 'PetID', 'PetID')
                    ->select(['PetID', 'Name']);
    }

    // ✅ Quan hệ đến Service giữ nguyên
    public function service()
    {
        return $this->belongsTo(Service::class, 'ServiceID', 'ServiceID');
    }
}
