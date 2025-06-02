<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $primaryKey = 'ServiceID';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'ServiceName',
        'Description',
        'Price',
        'CategoryID'
    ];

    public function category()
    {
        return $this->belongsTo(ServiceCategory::class, 'CategoryID', 'CategoryID');
    }
}
