<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    protected $table = 'Invoices';
    protected $primaryKey = 'InvoiceID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'PetID',
        'CreatedAt',
        'TotalAmount',
    ];
}
