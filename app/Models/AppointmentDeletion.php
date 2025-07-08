<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppointmentDeletion extends Model
{
    use HasFactory;

    protected $table = 'appointment_deletions';
    protected $primaryKey = 'DeletionID'; // Cột khóa chính trong bảng appointment_deletions
    public $timestamps = false; // Nếu bạn không sử dụng timestamps trong bảng này

    protected $fillable = [
        'appointment_id',
        'reason',
        'created_at', // Nếu bảng có thời gian tạo, bạn có thể thêm vào
    ];

    // Quan hệ với bảng appointments
    public function appointment()
    {
        return $this->belongsTo(Appointment::class, 'appointment_id', 'AppointmentID');
    }
}
