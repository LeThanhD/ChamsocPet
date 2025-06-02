<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ServiceCategory extends Model
{
    protected $table = 'servicecategories';
    protected $primaryKey = 'CategoryID';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'CategoryID',
        'CategoryName'
    ];

    public $timestamps = false;

    public function services()
    {
        return $this->hasMany(Service::class, 'CategoryID', 'CategoryID');
    }
}
