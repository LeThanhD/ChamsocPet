<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserLogs extends Model
{
    protected $table = 'userlogs';
    protected $primaryKey = 'LogID';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'LogID',
        'UserID',
        'ActionType',
        'ActionDetail',
        'ActionTime'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'UserID', 'UserID');
    }
}
