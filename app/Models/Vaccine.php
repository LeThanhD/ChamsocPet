<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Vaccine extends Model
{
    protected $table = 'vaccines';
    protected $primaryKey = 'VaccineID';

    public $timestamps = true;

    protected $fillable = [
        'Name',
        'Description',
    ];
}
