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
        'Price',  // Thêm vào để cho phép cập nhật cột Price
    ];

    protected $casts = [
        'AppointmentDate' => 'date',
        'AppointmentTime' => 'datetime:H:i:s',
        'Price' => 'decimal:2', // Đảm bảo Price được cast đúng kiểu decimal
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
    // ✅ Quan hệ nhiều dịch vụ đã chọn
    public function service()
    {
        return $this->belongsTo(Service::class, 'ServiceID', 'ServiceID');
    }

    // Nhiều dịch vụ từ bảng trung gian
    public function services()
    {
        return $this->belongsToMany(Service::class, 'appointment_service', 'appointment_id', 'service_id')
                    ->select(['services.ServiceID', 'services.ServiceName', 'services.Price']); // thêm trường Price
    }


    // ✅ Quan hệ đến bảng appointment_deletions (Lý do xóa)
    public function deletions()
    {
        return $this->hasMany(AppointmentDeletion::class, 'appointment_id', 'AppointmentID');
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
