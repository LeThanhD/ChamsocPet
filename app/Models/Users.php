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

    // Ghi đè để Laravel biết dùng PasswordHash thay vì 'password'
    public function getAuthPassword()
    {
        return $this->PasswordHash;
    }

    protected $hidden = [
        'PasswordHash',     // Ẩn mật khẩu khỏi JSON
        'NationalID',       // Ẩn nếu không muốn lộ thông tin nhạy cảm
        'tokens',           // Nếu bạn có quan hệ với Sanctum tokens
    ];
}
