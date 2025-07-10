<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail; 
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class Users extends Authenticatable implements MustVerifyEmail
{
    use HasApiTokens, Notifiable;

    protected $table = 'users';
    protected $primaryKey = 'UserID';
    public $incrementing = false;
    public $timestamps = false;
    protected $keyType = 'string';

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
        'CreatedAt',
        'fcm_token',
        'email_verified_at', // ✅ thêm cột này vào nếu chưa có
    ];

    protected $hidden = [
        'PasswordHash',
        'NationalID',
        'tokens',
    ];

    protected $casts = [
        'CreatedAt' => 'datetime',
        'BirthDate' => 'date',
        'email_verified_at' => 'datetime', // ✅ convert sang datetime
    ];

    public function getAuthPassword()
    {
        return $this->PasswordHash;
    }

    public function pets()
    {
        return $this->hasMany(Pet::class, 'UserID', 'UserID');
    }

    public function appointments()
    {
        return $this->hasMany(Appointment::class, 'UserID', 'UserID');
    }

    public function prescriptions()
    {
        return $this->hasMany(Prescription::class, 'UserID', 'UserID');
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class, 'UserID', 'UserID');
    }

    public function userLogs()
    {
        return $this->hasMany(UserLog::class, 'UserID', 'UserID');
    }

    public function scopeRole($query, $role)
    {
        return $query->whereRaw('LOWER(TRIM(Role)) = ?', [strtolower(trim($role))]);
    }
}
