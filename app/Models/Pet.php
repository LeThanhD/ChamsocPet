<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\PetNotes;
use App\Models\Users;

class Pet extends Model
{
    use HasFactory;

    protected $table = 'pets';
    protected $primaryKey = 'PetID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'PetID',
        'Name',
        'Gender',
        'FurColor',
        'Species',
        'Breed',
        'BirthDate',
        'Weight',
        'UserID',
        'fur_type',
        'origin',
        'vaccinated',
        'last_vaccine_date',
        'trained'
    ];

    protected static function boot()
    {
        parent::boot();

        static::deleting(function ($pet) {
            $pet->notes()->delete();
        });
    }

    public function notes()
    {
        return $this->hasMany(PetNotes::class, 'PetID', 'PetID');
    }

    public function latestNote()
    {
        return $this->hasOne(PetNotes::class, 'PetID', 'PetID')->orderByDesc('CreatedAt');
    }

    public function user()
    {
        return $this->belongsTo(Users::class, 'UserID', 'UserID');
        
    }
}
