<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class Users extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $table = 'users';
    protected $primaryKey = 'UserID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'UserID',
        'Username',
        'PasswordHash',
        'FullName',
        'Gender',
        'BirthDate',
        'Phone',
        'Address',
        'Email',
        'NationalID',
        'ProfilePicture',
        'Role',
        'Status',
        'CreatedAt'
    ];

    protected $hidden = [
        'PasswordHash',
        'NationalID',
        'tokens',
    ];

    protected $casts = [
        'CreatedAt' => 'datetime',
        'BirthDate' => 'date',
    ];

    // Ghi đè phương thức để Laravel dùng PasswordHash làm mật khẩu
    public function getAuthPassword()
    {
        return $this->PasswordHash;
    }

    // Quan hệ: người dùng có nhiều thú cưng
    public function pets()
    {
        return $this->hasMany(Pet::class, 'UserID', 'UserID');
    }

    // Quan hệ: người dùng có nhiều lịch hẹn
    public function appointments()
    {
        return $this->hasMany(Appointment::class, 'UserID', 'UserID');
    }

    // Quan hệ: người dùng có nhiều đơn thuốc
    public function prescriptions()
    {
        return $this->hasMany(Prescription::class, 'UserID', 'UserID');
    }

    // Quan hệ: người dùng có nhiều hóa đơn
    public function invoices()
    {
        return $this->hasMany(Invoice::class, 'UserID', 'UserID');
    }

    // Quan hệ: người dùng có nhiều log
    public function userLogs()
    {
        return $this->hasMany(UserLog::class, 'UserID', 'UserID');
    }

    // Scope: lọc theo vai trò
    public function scopeRole($query, $role)
    {
        return $query->whereRaw('LOWER(TRIM(Role)) = ?', [strtolower(trim($role))]);
    }
}
