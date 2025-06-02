<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $table = 'users';
    protected $primaryKey = 'UserID';
    public $incrementing = false;
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
        'CreatedAt'
    ];

    public $timestamps = false;
}

