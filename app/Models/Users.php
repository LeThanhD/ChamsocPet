<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Users extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $table = 'Users';
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

    /**
     * Laravel mặc định gọi cột "password" => cần override
     */
    public function getAuthPassword()
    {
        return $this->PasswordHash;
    }

    /**
     * Laravel mặc định gọi cột "email" để xác định người dùng => cần override
     */
    public function getAuthIdentifierName()
    {
        return 'Username';
    }
}
