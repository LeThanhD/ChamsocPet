<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pet extends Model
{
    protected $table = 'pets';
    protected $primaryKey = 'PetID';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'PetID',
        'Name',
        'Species',
        'Breed',
        'BirthDate',
        'Gender',
        'Weight',
        'FurColor',
        'UserID'
    ];
}
